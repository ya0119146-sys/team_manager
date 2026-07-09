import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for sensitive data (JWT tokens).
///
/// Uses platform-level encryption (Keychain on iOS, EncryptedSharedPreferences
/// on Android) to keep tokens safe at rest.
class SecureStorageHelper {
  SecureStorageHelper._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─────────────────────── Keys ───────────────────────
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'username';

  // ─────────────────────── Token ──────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ─────────────────────── Username ───────────────────
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<void> deleteUsername() async {
    await _storage.delete(key: _usernameKey);
  }

  // ─────────────────────── Clear All ──────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ─────────────────────── Generic ────────────────────
  static Future<void> write({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}
