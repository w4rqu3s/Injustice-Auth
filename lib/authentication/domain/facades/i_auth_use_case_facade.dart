import 'package:injustice_app/core/typedefs/types_defs.dart';

abstract interface class IAuthUseCaseFacade {
  Future<AuthSessionResult> signInUseCase(SignInParams params);
  Future<AuthSessionResult> signInWithGoogleUseCase(NoParams params);
  Future<VoidResult> signOutUseCase(NoParams params);
  Future<AuthSessionResult> signUpUseCase(SignUpParams params);
  // Dados mock para fallback
  // CurrencyResult getMockCurrency();
  // CurrencyListResult getMockCurrencies();
  // HistoricalQuotesResult getMockHistoricalQuotes();
}
