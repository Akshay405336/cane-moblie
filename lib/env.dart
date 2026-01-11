/// lib/env.dart
class Env {
  /// Change this when moving to production
  static const bool isProd = false;

  /// Base API URL
  /// DEV: local backend over Wi-Fi (Android real device)
  /// PROD: real domain
  static const String baseUrl = isProd
      ? 'https://api.yourdomain.com'
      : 'https://192.168.1.5:4000';

  /// App name
  static const String appName = 'Cane & Tender';
}
