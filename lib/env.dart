/// lib/env.dart
class Env {
  /// Change this when moving to production
  static const bool isProd = false;

  /// Base API URL
  /// DEV: ngrok tunnel (real mobile devices)
  /// PROD: real domain
  static const String baseUrl = isProd
      ? 'https://api.yourdomain.com'
      : 'https://platinum-jackets-gloves-stays.trycloudflare.com';

  /// App name
  static const String appName = 'Cane & Tender';
}
