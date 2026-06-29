import 'dart:async';

import 'package:injustice_app/core/failure/failure.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/patterns/command.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../domain/models/auth_entities.dart';
import '../commands/auth_commands.dart';
import 'auth_session_state_viewmodel.dart';

class AuthSessionCommands {
  final AuthSessionState state;
  final SignInCommand _signInCommand;
  final SignInWithGoogleCommand _signInWithGoogleCommand;
  final SignOutCommand _signOutCommand;
  final SignUpCommand _signUpCommand;
  final IAuthRepository _repository;

 

  AuthSessionCommands({
    required this.state,
    required IAuthRepository repository,
    required SignInCommand signInCommand,
    required SignInWithGoogleCommand signInWithGoogleCommand,
    required SignOutCommand signOutCommand,
    required SignUpCommand signUpCommand,
  }) : _repository = repository,
       _signInCommand = signInCommand,
       _signInWithGoogleCommand = signInWithGoogleCommand,
       _signOutCommand = signOutCommand,
       _signUpCommand = signUpCommand {
    // Observadores que reagem automaticamente ao término dos comandos
    _observeSignIn();
    _observeSignInWithGoogle();
    _observeSignUp();
    _observeSignOut();
    _observeSession();
  }

  // ========================================================
  //   GETTERS PARA WIDGETS USAREM DIRETAMENTE OS COMANDOS
  // ========================================================
  SignInCommand get signInCommand => _signInCommand;
  SignInWithGoogleCommand get signInWithGoogleCommand =>
      _signInWithGoogleCommand;
  SignOutCommand get signOutCommand => _signOutCommand;
  SignUpCommand get signUpCommand => _signUpCommand;

  // ========================================================
  //   MÉTODOS PÚBLICOS (CHAMADOS PELOS WIDGETS)
  //   que disparam os commands
  // ========================================================
  Future<void> signOut() async {
    state.clearMessage();
    await _signOutCommand.executeWith(()); // dispara o comando
  }

  Future<void> signInWithGoogle() async {
    state.clearMessage();
    await _signInWithGoogleCommand.executeWith(()); // dispara o comando
  }

  Future<void> signIn(String email, String password) async {
    state.clearMessage();
    // dispara o comando
    await _signInCommand.executeWith((email: email, password: password));
  }

  Future<void> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    state.clearMessage();
    // dispara o comando
    await _signUpCommand.executeWith((
      name: name,
      email: email,
      password: password,
    ));
  }

  // ========================================================
  //   MÉTODO GENÉRICO DE OBSERVAÇÃO DE COMANDOS
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      // 1) Ignora enquanto está executando
      if (command.isExecuting.value) return;

      // 2) Ignora até existir um resultado
      final result = command.result.value;
      if (result == null) return;

      // 3) Sucesso ou falha
      result.fold(
        onSuccess: (data) {
          state.clearMessage(); // sempre limpa erros em sucesso
          onSuccess(data); // ação específica para esse comando
        },
        onFailure: (err) {
          state.setMessage(err.msg); // registra o erro no estado
          if (onFailure != null) onFailure(err);
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS ESPECÍFICOS
  // ========================================================
  // Efetuar a sign-out
  void _observeSignOut() {
    _observeCommand<void>(
      _signOutCommand,
      onSuccess: (_) {
        state.setUnauthenticated(msg: 'Sessão Encerrada');
      },
    );
  }

  // Efetuar a sign-in com google
  void _observeSignInWithGoogle() {
    _observeCommand<AuthSession>(
      _signInWithGoogleCommand,
      onSuccess: (authSession) {
        state.setAuthenticated(authSession);
      },
      onFailure: (err) {
        state.setUnauthenticated(msg: err.msg);
      },
    );
  }

  // Efetuar a sign-in com login e senha
  void _observeSignIn() {
    _observeCommand<AuthSession>(
      _signInCommand,
      onSuccess: (authSession) {
        state.setAuthenticated(authSession);
      },
      onFailure: (err) {
        state.setUnauthenticated(msg: err.msg);
      },
    );
  }

  // Registra um novo usuário
  void _observeSignUp() {
    _observeCommand<AuthSession>(
      _signUpCommand,
      onSuccess: (authSession) {
        state.setAuthenticated(authSession);
      },
      onFailure: (err) {
        state.setUnauthenticated(msg: err.msg);
      },
    );
  }

  // Effect reativo que observa a sessão do atual
  // Executa automaticamente sempre que o signal da sessão mudar
  void _observeSession() {
    effect(() {
      final authSession = _repository.sessionSignal.value;

      if (authSession == null) {
        state.setUnauthenticated();
      } else if (authSession.token.isExpired) {
        state.setExpired(msg: 'Sessão expirada');
        unawaited(_repository.signOut());
      } else {
        state.setAuthenticated(authSession);
      }
    });
  }
}
