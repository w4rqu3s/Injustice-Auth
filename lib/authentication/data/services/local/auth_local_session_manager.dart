
import '../../../domain/models/session_token.dart';
import 'i_local_session_store.dart';

class AuthLocalSessionManager {
  final ILocalSessionStore store;
  AuthLocalSessionManager(this.store);

  Future<void> setToken(SessionToken? token) => store.save(token);

  Future<SessionToken?> getToken() => store.read();

  Future<SessionToken?> getValidToken() async {
    final token = await store.read();
    if (token == null) return null;
    if (token.isExpired) return null;
    return token;
  }

  Future<bool> hasValidSession() async => (await getValidToken()) != null;

  Future<void> clear() => store.clear();
}