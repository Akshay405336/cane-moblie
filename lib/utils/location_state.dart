import 'secure_storage.dart';

class LocationState {
  LocationState._();

  static const _locationKey = 'device_location_address';

  static String? _address;

  // 🔄 Detecting state (for shimmer / loading UI)
  static bool _isDetecting = false;

  // ❌ Error state (GPS off / permission denied)
  static String? _errorMessage;

  /* ================================================= */
  /* GETTERS                                          */
  /* ================================================= */

  /// Whether we have a valid cached address
  static bool get hasLocation =>
      _address != null && _address!.trim().isNotEmpty;

  /// Text shown in header
  static String get address =>
      hasLocation ? _address! : 'Select location';

  /// Whether location detection is in progress
  static bool get isDetecting => _isDetecting;

  /// Whether there is a location error
  static bool get hasError => _errorMessage != null;

  /// Error message for UI
  static String get errorMessage =>
      _errorMessage ?? 'Unable to detect location';

  /* ================================================= */
  /* LIFECYCLE                                        */
  /* ================================================= */

  /// Load persisted location (called on app start)
  /// ⚠️ Does NOT trigger detection
  static Future<void> load() async {
    final stored = await SecureStorage.read(_locationKey);
    _address = stored?.trim().isEmpty == true ? null : stored;
  }

  /* ================================================= */
  /* MUTATORS                                         */
  /* ================================================= */

  /// Call when live location detection starts
  static void startDetecting() {
    _isDetecting = true;
    _errorMessage = null; // clear stale error
  }

  /// Call ONLY after detection completes (success or fail)
  static void stopDetecting() {
    _isDetecting = false;
  }

  /// Save + persist detected address (SUCCESS)
  static Future<void> setAddress(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
  }

  /// Set error (FAILURE)
  static void setError(String message) {
    _errorMessage = message;
    _isDetecting = false;
  }

  /// Clear error (before retry)
  static void clearError() {
    _errorMessage = null;
  }

  /// Full reset (logout / manual clear)
  static Future<void> clear() async {
    _address = null;
    _isDetecting = false;
    _errorMessage = null;
    await SecureStorage.delete(_locationKey);
  }
}
