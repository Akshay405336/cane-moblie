/// lib/network/auth_headers.dart
import '../utils/device_info.dart';

class AuthHeaders {
  /// Headers that should be sent with EVERY request
  static Future<Map<String, String>> baseHeaders() async {
    final deviceId = await DeviceInfo.getDeviceId();

    return {
      'Content-Type': 'application/json',
      'x-client-type': 'mobile',
      'x-device-id': deviceId,
    };
  }
}
