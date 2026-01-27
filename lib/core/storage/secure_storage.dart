/// core/storage/secure_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /* ================================================= */
  /* ================= AUTH KEYS ===================== */
  /* ================================================= */

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _accessExpiryKey = 'auth_access_expiry';
  static const _refreshExpiryKey = 'auth_refresh_expiry';

  /* ================================================= */
  /* ================= AUTH API ====================== */
  /* ================================================= */

  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(
        key: _accessExpiryKey,
        value: accessExpiry.toIso8601String(),
      ),
      _storage.write(
        key: _refreshExpiryKey,
        value: refreshExpiry.toIso8601String(),
      ),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<DateTime?> _readDate(String key) async {
    final v = await _storage.read(key: key);
    return v != null ? DateTime.tryParse(v) : null;
  }

  static Future<DateTime?> getAccessTokenExpiry() =>
      _readDate(_accessExpiryKey);

  static Future<DateTime?> getRefreshTokenExpiry() =>
      _readDate(_refreshExpiryKey);

  /// 🔐 Clears ONLY auth (safe logout)
  static Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessExpiryKey),
      _storage.delete(key: _refreshExpiryKey),
    ]);
  }

  /* ================================================= */
  /* ============ GENERIC NON-AUTH API =============== */
  /* ================================================= */

  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) =>
      _storage.read(key: key);

  static Future<void> delete(String key) =>
      _storage.delete(key: key);

  /* ================================================= */
  /* SAFE HELPERS FOR FEATURES                        */
  /* ================================================= */

  /// ⭐ delete multiple keys (PERFECT for location clear)
  static Future<void> deleteMany(List<String> keys) async {
    await Future.wait(keys.map((k) => _storage.delete(key: k)));
  }

  static Future<void> writeDouble(String key, double value) =>
      write(key, value.toString());

  static Future<double?> readDouble(String key) async {
    final v = await read(key);
    return v != null ? double.tryParse(v) : null;
  }

  /// ⭐ future-proof (optional but useful)
  static Future<void> writeJson(String key, Map<String, dynamic> value) =>
      write(key, jsonEncode(value));

  static Future<Map<String, dynamic>?> readJson(String key) async {
    final v = await read(key);
    return v != null ? jsonDecode(v) : null;
  }

  /* ================================================= */
  /* DEBUG / FULL RESET (DANGEROUS)                    */
  /* ================================================= */

  /// ⚠ wipes EVERYTHING including auth
  static Future<void> clearAll() => _storage.deleteAll();
}
