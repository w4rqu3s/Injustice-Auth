import 'package:injustice_app/core/failure/failure.dart';
import 'package:injustice_app/core/typedefs/types_defs.dart';

import '../../../core/patterns/command.dart';
import '../../../core/patterns/result.dart';
import '../../domain/facades/i_auth_use_case_facade.dart';
import '../../domain/models/auth_entities.dart';

final class SignInCommand extends ParameterizedCommand<AuthSession, Failure, SignInParams> {
  final IAuthUseCaseFacade _authUseCaseFacade;

  SignInCommand(this._authUseCaseFacade);

  @override
  Future<AuthSessionResult> execute() async {
    if (parameter == null || parameter!.email.isEmpty || parameter!.password.isEmpty) {
      return Error(InvalidInputFailure('Parâmetros de login inválidos.'));
    }

    return await _authUseCaseFacade.signInUseCase(parameter!);
  }
}

final class SignInWithGoogleCommand extends ParameterizedCommand<AuthSession, Failure, NoParams> {
  final IAuthUseCaseFacade _authUseCaseFacade;

  SignInWithGoogleCommand(this._authUseCaseFacade);

  @override
  Future<AuthSessionResult> execute() async {
    if (parameter == null) {
      return Error(InvalidInputFailure('Parâmetros de login Gooogle inválidos.'));
    }
    return await _authUseCaseFacade.signInWithGoogleUseCase(parameter!);
  }
}

final class SignOutCommand extends ParameterizedCommand<void, Failure, NoParams> {
  final IAuthUseCaseFacade _authUseCaseFacade;

  SignOutCommand(this._authUseCaseFacade);

  @override
  Future<VoidResult> execute() async {
    if (parameter == null) {
      return Error(InvalidInputFailure('Erro ao realir sign-out.'));
    }
    return await _authUseCaseFacade.signOutUseCase(parameter!);
  }
}

final class SignUpCommand extends ParameterizedCommand<AuthSession, Failure, SignUpParams> {
  final IAuthUseCaseFacade _authUseCaseFacade;

  SignUpCommand(this._authUseCaseFacade);

  @override
  Future<AuthSessionResult> execute() async {
    if (parameter == null || parameter!.email.isEmpty || parameter!.password.isEmpty) {
      return Error(InvalidInputFailure('Parâmetros de registro inválidos.'));
    }

    return await _authUseCaseFacade.signUpUseCase(parameter!);
  }
} 

