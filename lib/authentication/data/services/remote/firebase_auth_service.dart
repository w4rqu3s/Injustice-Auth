import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injustice_app/core/failure/failure.dart';
import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../../core/patterns/result.dart';
import '../../../domain/models/auth_entities.dart';
import '../../../domain/models/session_token.dart';
import '../local/auth_local_session_manager.dart';
import 'i_auth_service.dart';

/// Serviço de autenticação que utiliza o FirebaseAuth.
class FirebaseAuthService implements IAuthService {
  /// Instância do FirebaseAuth (injetYável para testes)
  final fb.FirebaseAuth _firebaseAuth;

  /// Gerenciador de sessão local
  final AuthLocalSessionManager _localSession;

  /// Signal reativo que mantém a sessão atual do usuário
  final Signal<AuthSession?> _currentSessionSignal = Signal<AuthSession?>(null);

  /// Construtor
  /// Se não for fornecido, usa a instância padrão do FirebaseAuth
  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    required AuthLocalSessionManager localSession,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _localSession = localSession {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Método interno chamado sempre que o Firebase detecta mudança no usuário
  /// (login, logout, token renovado, etc)
  void _onAuthStateChanged(fb.User? user) async {
    if (user == null) {
      _currentSessionSignal.value = null;
      return;
    }

    // Se já existe sessão ativa, NÃO recrie
    if (_currentSessionSignal.value != null) {
      return;
    }

    // Aqui significa: usuário logou AGORA pela primeira vez
    final tokenStr = await user.getIdToken() ?? '';

    // expiração manual fixa (1h)
    final tokenExp = DateTime.now().add(const Duration(hours: 1));

    final session = AuthSession(
      user: User(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      ),
      token: Token(value: tokenStr, expiresAt: tokenExp),
    );

    // salva sessão local
    final sessionToken = SessionToken(
      uid: session.user.id,
      name: session.user.name,
      email: session.user.email,
      value: tokenStr,
      expiresAt: tokenExp,
      refreshToken: null,
      provider: AuthProvider.firebase,
    );

    await _localSession.setToken(sessionToken);

    _currentSessionSignal.value = session;
  }

  // -----------------------------
  // Getters públicos
  // -----------------------------

  /// Retorna o Signal reativo da sessão
  @override
  Signal<AuthSession?> get currentSessionSignal => _currentSessionSignal;

  /// Retorna a sessão atual ou null se não houver usuário logado
  @override
  AuthSession? get currentSession => _currentSessionSignal.value;

  // -----------------------------
  // Métodos de autenticação
  // -----------------------------

  /// Login com email e senha
  /// Retorna AuthSessionResult: Success(AuthSession) ou Error(Failure)
  @override
  Future<AuthSessionResult> signIn(String email, String password) async {
    try {
      // Tenta logar com o Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Se login bem-sucedido, obtém token e cria AuthSession
        final tokenStr = await user.getIdToken() ?? '';
        final tokenExp = DateTime.now().add(const Duration(hours: 1));

        // Cria objeto AuthSession
        final session = AuthSession(
          user: User(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
          ),
          token: Token(value: tokenStr, expiresAt: tokenExp),
        );

        // Cria SessionToken para armazenamento local
        final sessionToken = SessionToken(
          uid: session.user.id,
          name: session.user.name,
          email: session.user.email,
          value: tokenStr,
          expiresAt: tokenExp,
          refreshToken: null,
          provider: AuthProvider.firebase,
        );

        // Salva sessão localmente
        await _localSession.setToken(sessionToken);

        return Success(session);
      }

      // Caso algo dê errado e não retorne usuário
      return Error(DefaultFailure('Usuário não encontrado'));
    } catch (e) {
      // Captura qualquer exceção do Firebase e retorna como Failure
      return Error(DefaultFailure(e.toString()));
    }
  }

  /// Login com conta do Google
  @override
  Future<AuthSessionResult> signInWithGoogle() async {
    try {
      // Inicia o fluxo de autenticação do Google
      //final googleUser = await GoogleSignIn().signIn();

      // Obtém a instância global do GoogleSignIn
      final googleSignIn = GoogleSignIn.instance;
      // Inicializa se necessário
      await googleSignIn.initialize();
      // Inicia o fluxo de login
      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      // Cria a credencial para o Firebase
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        // accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica no Firebase com a credencial do Google
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        return Error(DefaultFailure('Falha ao autenticar com o Google.'));
      }

      final tokenStr = await user.getIdToken() ?? '';
      final tokenExp = DateTime.now().add(const Duration(hours: 1));

      // Cria objeto AuthSession
      final session = AuthSession(
        user: User(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        ),
        token: Token(value: tokenStr, expiresAt: tokenExp),
      );

      // Cria e salva sessão local
      final sessionToken = SessionToken(
        uid: session.user.id,
        name: session.user.name,
        email: session.user.email,
        value: tokenStr,
        expiresAt: tokenExp,
        refreshToken: null,
        provider: AuthProvider.google,
      );

      // Salva sessão localmente
      await _localSession.setToken(sessionToken);

      return Success(session);
    } catch (e) {
      return Error(DefaultFailure(e.toString()));
    }
  }

  /// Registro com email, senha e nome opcional
  @override
  Future<AuthSessionResult> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      // Cria usuário no Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Atualiza displayName se nome foi fornecido
        if (name != null && name.isNotEmpty) {
          await user.updateDisplayName(name);
        }

        // Obtém token e cria sessão
        final tokenStr = await user.getIdToken() ?? '';
        final tokenExp = DateTime.now().add(const Duration(hours: 1));

        final session = AuthSession(
          user: User(
            id: user.uid,
            name: name ?? user.displayName ?? '',
            email: user.email ?? '',
          ),
          token: Token(value: tokenStr, expiresAt: tokenExp),
        );

        final sessionToken = SessionToken(
          uid: session.user.id,
          name: session.user.name,
          email: session.user.email,
          value: tokenStr,
          expiresAt: tokenExp,
          refreshToken: null,
          provider: AuthProvider.firebase,
        );

        // Salva sessão localmente
        await _localSession.setToken(sessionToken);

        return Success(session);
      }

      return Error(DefaultFailure('Falha ao criar usuário'));
    } catch (e) {
      return Error(DefaultFailure(e.toString()));
    }
  }

  /// Logout do usuário atual
  @override
  Future<VoidResult> signOut() async {
    await _localSession.clear();
    await _firebaseAuth.signOut();
    return Success(null);
  }

  /// Inicializa a sessão ao carregar o app
  /// Lê a sessão local primeiro e atualiza o Signal
  @override
  Future<void> initSession() async {
    final token = await _localSession.getValidToken();
    // print('dadado do token na initSession: $token');

    if (token != null) {
      // print(
      //   'dados do token na initSession: ${token.value}, expira em ${token.expiresAt}',
      // );
      // Se existe um token válido, cria sessão temporária
      _currentSessionSignal.value = AuthSession(
        user: User(
          id: token.uid,
          name: token.name ?? '',
          email: token.email ?? '',
        ),
        token: Token(value: token.value, expiresAt: token.expiresAt),
      );
    }
  }
}
