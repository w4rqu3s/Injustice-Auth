import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/auth_entities.dart';
import '../services/remote/i_auth_service.dart';
import 'i_auth_repository.dart';

/// Implementação concreta do repositório de autenticação
/// Encapsula o AuthService e fornece acesso reativo à sessão
class AuthRepositoryImpl implements IAuthRepository {
  /// Serviço de autenticação subjacente
  final IAuthService _authService;

  AuthRepositoryImpl(this._authService);

  /// Retorna a sessão atual (ou null se não houver usuário logado)
  @override
  AuthSession? get currentSession => _authService.currentSession;

  /// Signal reativo da sessão, repassa do service
  @override
  Signal<AuthSession?> get sessionSignal => _authService.currentSessionSignal;

  /// Realiza login com email e senha
  @override
  Future<AuthSessionResult> signIn(String email, String password) {
    return _authService.signIn(email, password);
  }
  /// Realiza login com Google
  @override
  Future<AuthSessionResult> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  /// Registro de usuário com email e senha. Name é opcional
  @override
  Future<AuthSessionResult> signUp({
    String? name,
    required String email,
    required String password,
  }) {
    return _authService.signUp(name: name, email: email, password: password);
  }

  /// Logout do usuário atual
  @override
  Future<VoidResult> signOut() {
    return _authService.signOut();
  }
}
