/// lib/network/http_client.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../env.dart';
import '../utils/secure_storage.dart';
import 'auth_headers.dart';
import 'token_interceptor.dart';

class AppHttpClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    /* -------------------------------------------------- */
    /* REQUEST INTERCEPTOR                                */
    /* -------------------------------------------------- */
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add base headers (x-client-type, x-device-id, content-type)
          final headers = await AuthHeaders.baseHeaders();
          options.headers.addAll(headers);

          // Add access token if available
          final accessToken =
              await SecureStorage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] =
                'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) {
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
        final client = HttpClient(); // dart:io HttpClient
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                true;
        return client;
      };
    }

    return dio;
  }
}
