/// lib/network/http_client.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../env.dart';
import '../../utils/secure_storage.dart';
import 'auth_headers.dart';
import 'token_interceptor.dart';

class AppHttpClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,

        /* ================================================= */
        /* ⭐⭐⭐ FIX: BIGGER TIMEOUTS (ngrok safe) ⭐⭐⭐         */
        /* ================================================= */

        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),

        responseType: ResponseType.json,
      ),
    );

    /* -------------------------------------------------- */
    /* REQUEST INTERCEPTOR                                */
    /* -------------------------------------------------- */

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final headers = await AuthHeaders.baseHeaders();
          options.headers.addAll(headers);

          final accessToken =
              await SecureStorage.getAccessToken();

          if (accessToken != null) {
            options.headers['Authorization'] =
                'Bearer $accessToken';
          }

          print(
              '🌍 HTTP → ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '✅ HTTP ← ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ HTTP ERROR → ${error.message}');
          handler.next(error);
        },
      ),
    );

    /* -------------------------------------------------- */
    /* TOKEN REFRESH INTERCEPTOR                          */
    /* -------------------------------------------------- */

    dio.interceptors.add(TokenInterceptor());

    /* -------------------------------------------------- */
    /* HTTPS (mkcert / self-signed) – DEV ONLY            */
    /* -------------------------------------------------- */

    if (!Env.isProd) {
      final adapter =
          dio.httpClientAdapter as IOHttpClientAdapter;

      adapter.createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                true;

        return client;
      };
    }

    return dio;
  }
}
