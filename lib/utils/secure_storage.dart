/// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /* ================================================= */
  /* KEYS                                             */
  /* ================================================= */

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessExpiryKey = 'access_token_expires_at';
  static const _refreshExpiryKey = 'refresh_token_expires_at';

  /* ================================================= */
  /* SAVE                                             */
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
  /* READ                                             */
  /* ================================================= */

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  static Future<DateTime?> getAccessTokenExpiry() async {
    final value =
        await _storage.read(key: _accessExpiryKey);
    return value != null ? DateTime.parse(value) : null;
  }

  static Future<DateTime?> getRefreshTokenExpiry() async {
    final value =
        await _storage.read(key: _refreshExpiryKey);
    return value != null ? DateTime.parse(value) : null;
  }

  /* ================================================= */
  /* CLEAR                                            */
  /* ================================================= */

  static Future<void> clearAuth() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessExpiryKey);
    await _storage.delete(key: _refreshExpiryKey);
  }
}
