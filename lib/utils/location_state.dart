import 'secure_storage.dart';

class LocationState {
  LocationState._();

  static const _locationKey = 'device_location_address';

  static String? _address;

  // 🔄 Detecting state (for shimmer / UI)
  static bool _isDetecting = false;

  /* ================================================= */
  /* GETTERS                                          */
  /* ================================================= */

  /// Whether location is already selected
  static bool get hasLocation => _address != null;

  /// Text shown in header
  static String get address => _address ?? 'Select location';

  /// Whether location is currently being detected
  static bool get isDetecting => _isDetecting;

  /* ================================================= */
  /* LIFECYCLE                                        */
  /* ================================================= */

  /// Load persisted location (call on app start)
  static Future<void> load() async {
    _address = await SecureStorage.read(_locationKey);
  }

  /* ================================================= */
  /* MUTATORS                                         */
  /* ================================================= */

  /// Call when location detection starts (show shimmer)
  static void startDetecting() {
    _isDetecting = true;
  }

  /// Call when location detection ends (hide shimmer)
  static void stopDetecting() {
    _isDetecting = false;
  }

  /// Save + persist location
  static Future<void> setAddress(String value) async {
    _address = value;
    await SecureStorage.write(_locationKey, value);
  }

  /// Optional (usually NOT used)
  static Future<void> clear() async {
    _address = null;
    _isDetecting = false;
    await SecureStorage.delete(_locationKey);
  }
}
