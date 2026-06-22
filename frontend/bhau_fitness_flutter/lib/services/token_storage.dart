import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so the rest of the app never touches the
/// underlying storage API directly — makes it trivial to swap later if needed.
///
/// Also backs the "Remember Me" checkbox on login: when [saveToken] is
/// called with `persist: false`, the token is kept in an in-memory cache
/// (so API calls still work for the rest of this session) but never written
/// to secure storage — a fresh page load won't find it, so the member is
/// asked to log in again next time, exactly like an unchecked "Remember Me".
class TokenStorage {
  static const _tokenKey = 'bhau_jwt_token';
  static const _storage = FlutterSecureStorage();
  static String? _memoryToken;

  Future<void> saveToken(String token, {bool persist = true}) async {
    _memoryToken = token;
    if (persist) {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> readToken() async {
    return _memoryToken ?? await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    _memoryToken = null;
    await _storage.delete(key: _tokenKey);
  }
}
