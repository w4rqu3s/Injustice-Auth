import 'package:injustice_app/core/typedefs/types_defs.dart';

import '../../data/repositories/i_auth_repository.dart';
import 'i_auth_usecases.dart';

final class SignInUseCase implements ISignInUseCase {
  final IAuthRepository _authRepository;

  SignInUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<AuthSessionResult> call(SignInParams params) async {
    return _authRepository.signIn(params.email, params.password);
  }
}

final class SignInWithGoogleUseCase implements ISignInWithGoogleUseCase {
  final IAuthRepository _authRepository;

  SignInWithGoogleUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<AuthSessionResult> call(NoParams params) async {
    return _authRepository.signInWithGoogle();
  }
}

final class SignOutUseCase implements ISignOutUseCase {
  final IAuthRepository _authRepository;

  SignOutUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<VoidResult> call(NoParams params) async {
    return _authRepository.signOut();
  }
}

final class SignUpUseCase implements ISignUpUseCase {
  final IAuthRepository _authRepository;

  SignUpUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<AuthSessionResult> call(SignUpParams params) async {
    return _authRepository.signUp(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}
