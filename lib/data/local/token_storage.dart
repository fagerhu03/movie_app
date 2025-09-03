// lib/data/local/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kAccess = 'access_token';

  Future<void> saveAccess(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAccess, token);
  }

  Future<String?> readAccess() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kAccess);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
  }
}
