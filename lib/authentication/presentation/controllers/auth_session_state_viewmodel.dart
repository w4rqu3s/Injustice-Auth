import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/models/auth_entities.dart';

/// Enum que representa o status de autenticação
enum AuthStatus { 
  unauthenticated, // Usuário não está logado
  authenticated,   // Usuário logado e token válido
  expired          // Sessão expirada
}

/// Estado reativo da sessão de autenticação
/// Mantém status, sessão atual e mensagens de erro/aviso
class AuthSessionState {
  /// Status atual da autenticação, inicializado como não autenticado
  final status = signal<AuthStatus>(AuthStatus.unauthenticated);

  /// Sessão atual (usuário + token), inicializada como nula
  final session = signal<AuthSession?>(null);

  /// Mensagem de erro ou aviso, inicializada como nula
  final message = signal<String?>(null);

  // ----------------------------------------------------------
  // Computed properties
  /// Retorna true se o usuário estiver autenticado e o token for válido
  bool get isAuthenticated {
    return status.value == AuthStatus.authenticated &&
      session.value != null &&
      session.value!.isValid;
  }
  /// Retorna true se a sessão estiver expirada
  bool get isExpired => status.value == AuthStatus.expired;

  // ----------------------------------------------------------
  // Métodos auxiliares 
  // ----------------------------------------------------------
  /// Define o estado como autenticado com a sessão fornecida
  void setAuthenticated(AuthSession authSession) {
    session.value = authSession;     // Atualiza a sessão
    status.value = AuthStatus.authenticated; // Atualiza o status
    message.value = null;             // Limpa mensagens anteriores
  }

  /// Define o estado como não autenticado, opcionalmente com uma mensagem
  void setUnauthenticated({String? msg}) {
    session.value = null;                  // Limpa sessão
    status.value = AuthStatus.unauthenticated; // Atualiza status
    message.value = msg;                   // Define mensagem de erro/opcional
  }

  /// Define o estado como expirado, opcionalmente com uma mensagem
  void setExpired({String? msg}) {
    status.value = AuthStatus.expired;    // Atualiza status
    message.value = msg ?? 'Sessão expirada'; // Mensagem padrão se não fornecida
  }

  /// Limpa qualquer mensagem de erro ou aviso
  void clearMessage() => message.value = null;

  /// Define uma mensagem de erro ou aviso
  void setMessage(String msg) => message.value = msg;
}
