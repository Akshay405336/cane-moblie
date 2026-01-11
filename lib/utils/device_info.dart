/// lib/utils/device_info.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceInfo {
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'device_id';

  /// Returns a persistent device ID.
  /// Generated once and stored securely.
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _storage.write(
        key: _deviceIdKey,
        value: deviceId,
      );
    }

    return deviceId;
  }
}
