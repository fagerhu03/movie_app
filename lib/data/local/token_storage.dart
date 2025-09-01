// lib/data/local/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccess = 'access_token';
  final _s = const FlutterSecureStorage();

  Future<void> saveAccess(String token) => _s.write(key: _kAccess, value: token);
  Future<String?> readAccess() => _s.read(key: _kAccess);
  Future<void> clear() => _s.delete(key: _kAccess);
}
