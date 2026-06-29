import 'package:injustice_app/core/typedefs/types_defs.dart';

import '../usecases/i_auth_usecases.dart';
import 'i_auth_use_case_facade.dart';

class AuthUseCaseFacadeImpl implements IAuthUseCaseFacade {
  final ISignInUseCase _signInUseCase;
  final ISignInWithGoogleUseCase _signInWithGoogleUseCase;
  final ISignOutUseCase _signOutUseCase;
  final ISignUpUseCase _signUpUseCase;

  AuthUseCaseFacadeImpl({
    required ISignInUseCase signInUseCase,
    required ISignInWithGoogleUseCase signInWithGoogleUseCase,
    required ISignOutUseCase signOutUseCase,
    required ISignUpUseCase signUpUseCase,
  }) : _signInUseCase = signInUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signOutUseCase = signOutUseCase,
       _signUpUseCase = signUpUseCase;

  @override
  Future<AuthSessionResult> signInUseCase(SignInParams params) {
    return _signInUseCase(params);
  }

  @override
  Future<AuthSessionResult> signInWithGoogleUseCase(NoParams params) {
    return _signInWithGoogleUseCase(params);
  }

  @override
  Future<VoidResult> signOutUseCase(NoParams params) {
    return _signOutUseCase(params);
  }

  @override
  Future<AuthSessionResult> signUpUseCase(SignUpParams params) {
    return _signUpUseCase(params);
  }
}
