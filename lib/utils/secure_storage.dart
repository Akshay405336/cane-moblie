/// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /* ================================================= */
  /* AUTH KEYS (DO NOT REUSE)                          */
  /* ================================================= */

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessExpiryKey = 'access_token_expires_at';
  static const _refreshExpiryKey = 'refresh_token_expires_at';

  /* ================================================= */
  /* SAVE AUTH                                        */
  /* ================================================= */

  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
    await _storage.write(
      key: _accessExpiryKey,
      value: accessExpiry.toIso8601String(),
    );
    await _storage.write(
      key: _refreshExpiryKey,
      value: refreshExpiry.toIso8601String(),
    );
  }

  /* ================================================= */
  /* READ AUTH                                        */
  /* ================================================= */

  static Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  static Future<DateTime?> getAccessTokenExpiry() async {
    final value = await _storage.read(
      key: _accessExpiryKey,
    );
    try {
      return value != null ? DateTime.parse(value) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<DateTime?> getRefreshTokenExpiry() async {
    final value = await _storage.read(
      key: _refreshExpiryKey,
    );
    try {
      return value != null ? DateTime.parse(value) : null;
    } catch (_) {
      return null;
    }
  }

  /* ================================================= */
  /* CLEAR AUTH (ONLY AUTH!)                           */
  /* ================================================= */

  static Future<void> clearAuth() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessExpiryKey);
    await _storage.delete(key: _refreshExpiryKey);
  }

  /* ================================================= */
  /* GENERIC KEY-VALUE (NON-AUTH SAFE)                 */
  /* ================================================= */

  static Future<void> write(
    String key,
    String value,
  ) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  static Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  /* ================================================= */
  /* DEBUG / FULL RESET (RARE USE)                     */
  /* ================================================= */

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
