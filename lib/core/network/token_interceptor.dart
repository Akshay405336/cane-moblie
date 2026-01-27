/// lib/network/token_interceptor.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../env.dart';
import '../../utils/secure_storage.dart';
import 'api_endpoints.dart';
import 'auth_headers.dart';

class TokenInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('🛑 TOKEN INTERCEPTOR HIT');
      debugPrint('❌ STATUS : ${err.response?.statusCode}');
      debugPrint('❌ PATH   : ${err.requestOptions.uri}');
      debugPrint('❌ METHOD : ${err.requestOptions.method}');
    }

    // Only handle 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite loops
    if (_isRefreshing) {
      if (kDebugMode) {
        debugPrint('🔁 Already refreshing → skip');
      }
      return handler.next(err);
    }

    final refreshToken = await SecureStorage.getRefreshToken();

    if (refreshToken == null) {
      if (kDebugMode) {
        debugPrint('🚪 No refresh token → clearing auth');
      }
      await SecureStorage.clearAuth();
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      /* ================================================= */
      /* BARE DIO (NO INTERCEPTORS)                        */
      /* ================================================= */
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      );

      // ✅ Allow self-signed certs in DEV
      if (!Env.isProd) {
        final adapter =
            refreshDio.httpClientAdapter as IOHttpClientAdapter;
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }

      final baseHeaders = await AuthHeaders.baseHeaders();

      if (kDebugMode) {
        debugPrint('🔄 REFRESHING SESSION');
      }

      /* ================================================= */
      /* REFRESH SESSION                                  */
      /* ================================================= */
      final refreshResponse = await refreshDio.post(
        ApiEndpoints.refreshSession,
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          validateStatus: (_) => true,
          headers: {
            ...baseHeaders,
            'x-client-type': 'mobile',
          },
        ),
      );

      if (refreshResponse.statusCode != 200 &&
          refreshResponse.statusCode != 201) {
        throw Exception('Refresh failed');
      }

      final data = refreshResponse.data['data'];
      if (data == null) {
        throw Exception('Invalid refresh payload');
      }

      if (kDebugMode) {
        debugPrint('✅ TOKEN REFRESH SUCCESS');
      }

      /* ================================================= */
      /* SAVE NEW TOKENS                                  */
      /* ================================================= */
      await SecureStorage.saveAuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        accessExpiry:
            DateTime.parse(data['accessTokenExpiresAt']),
        refreshExpiry:
            DateTime.parse(data['refreshTokenExpiresAt']),
      );

      /* ================================================= */
      /* RETRY ORIGINAL REQUEST (CLEAN HEADERS)           */
      /* ================================================= */
      final newAccessToken = await SecureStorage.getAccessToken();

      final retryResponse = await refreshDio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          validateStatus: (_) => true,
          headers: {
            'Content-Type': 'application/json',
            'x-client-type': 'mobile',
            'Authorization': 'Bearer $newAccessToken',
          },
        ),
      );

      if (retryResponse.statusCode == 401) {
        throw Exception('Retry unauthorized');
      }

      return handler.resolve(retryResponse);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TOKEN REFRESH FAILED');
        debugPrint('❌ ERROR: $e');
      }
      await SecureStorage.clearAuth();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
