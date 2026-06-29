import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/auth_entities.dart';

/// Interface para o repositório de autenticação
abstract class IAuthRepository {
  /// Retorna a sessão atual, ou null se não houver usuário logado
  AuthSession? get currentSession;

  /// Signal reativo da sessão atual
  Signal<AuthSession?> get sessionSignal;

  /// Login com email e senha
  Future<AuthSessionResult> signIn(String email, String password);

  /// login com Google
  Future<AuthSessionResult> signInWithGoogle();

  /// Registro com email e senha. Name é opcional
  Future<AuthSessionResult> signUp({
    String? name,
    required String email,
    required String password,
  });

  /// Logout do usuário atual
  Future<VoidResult> signOut();
}
