import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../domain/models/auth_entities.dart';

abstract interface class IAuthService {
  /// Retorna a sessão atual, ou null se não houver usuário logado
  /// um Signal para reatividade
  Signal<AuthSession?> get currentSessionSignal;

  AuthSession? get currentSession => null;
  
  /// Inicializa a sessão carregando token local
  Future<void> initSession();
  
  /// Login com email e senha
  Future<AuthSessionResult> signIn(String email, String password);
  
  /// Login com Google
  Future<AuthSessionResult> signInWithGoogle();

  /// Registro com email e senha. Name é opcional.
  Future<AuthSessionResult> signUp({
    String? name,
    required String email,
    required String password,
  });

  /// Logout do usuário atual
  Future<VoidResult> signOut();
  
}
