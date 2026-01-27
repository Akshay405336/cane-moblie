import './http_client.dart';

class UrlHelper {
  static String full(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http')) return path;

    final base = AppHttpClient.dio.options.baseUrl;

    return '$base/$path';
  }
}
