import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/session_token.dart';
import 'i_local_session_store.dart';

class SharedPrefLocalSessionService implements ILocalSessionStore {
  static const _key = 'auth.session.token.v1';

  @override
  Future<void> save(SessionToken? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, jsonEncode(token.toJson()));
    }
  }

  @override
  Future<SessionToken?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = SessionToken.fromJson(map);
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
