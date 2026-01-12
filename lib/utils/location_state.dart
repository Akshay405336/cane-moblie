import 'secure_storage.dart';

enum AddressSource {
  gps,
  saved,
}

class LocationState {
  LocationState._();

  static const _locationKey = 'device_location_address';
  static const _addressSourceKey = 'active_address_source';
  static const _activeSavedIdKey = 'active_saved_address_id';

  static String? _address;
  static AddressSource? _source;
  static String? _activeSavedAddressId;

  // 🔄 Detecting state (for shimmer / loading UI)
  static bool _isDetecting = false;

  // ❌ Error state
  static String? _errorMessage;

  /* ================================================= */
  /* GETTERS                                          */
  /* ================================================= */

  static bool get hasLocation =>
      _address != null && _address!.trim().isNotEmpty;

  static String get address =>
      hasLocation ? _address! : 'Select location';

  static bool get isDetecting => _isDetecting;

  static bool get hasError => _errorMessage != null;

  static String get errorMessage =>
      _errorMessage ?? 'Unable to detect location';

  static AddressSource? get source => _source;

  static bool get isGpsAddress => _source == AddressSource.gps;

  static bool get isSavedAddress => _source == AddressSource.saved;

  static String? get activeSavedAddressId => _activeSavedAddressId;

  /* ================================================= */
  /* LIFECYCLE                                        */
  /* ================================================= */

  /// Load persisted location (called on app start)
  /// ⚠️ Does NOT trigger detection
  static Future<void> load() async {
    final storedAddress = await SecureStorage.read(_locationKey);
    final storedSource = await SecureStorage.read(_addressSourceKey);
    final savedId = await SecureStorage.read(_activeSavedIdKey);

    _address =
        storedAddress?.trim().isEmpty == true ? null : storedAddress;

    if (storedSource == 'saved') {
      _source = AddressSource.saved;
      _activeSavedAddressId = savedId;
    } else if (storedSource == 'gps') {
      _source = AddressSource.gps;
    }
  }

  /* ================================================= */
  /* GPS FLOW (UNCHANGED)                              */
  /* ================================================= */

  static void startDetecting() {
    _isDetecting = true;
    _errorMessage = null;
  }

  static void stopDetecting() {
    _isDetecting = false;
  }

  /// Called ONLY after GPS detection success
  static Future<void> setAddress(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _source = AddressSource.gps;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'gps');
    await SecureStorage.delete(_activeSavedIdKey);
  }

  /* ================================================= */
  /* SAVED ADDRESS FLOW (NEW)                          */
  /* ================================================= */

  /// Select an already saved address (NO GPS)
  static Future<void> setSavedAddress({
    required String id,
    required String address,
  }) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _source = AddressSource.saved;
    _activeSavedAddressId = id;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'saved');
    await SecureStorage.write(_activeSavedIdKey, id);
  }

  /* ================================================= */
  /* ERROR & RESET                                     */
  /* ================================================= */

  static void setError(String message) {
    _errorMessage = message;
    _isDetecting = false;
  }

  static void clearError() {
    _errorMessage = null;
  }

  static Future<void> clear() async {
    _address = null;
    _source = null;
    _activeSavedAddressId = null;
    _isDetecting = false;
    _errorMessage = null;

    await SecureStorage.delete(_locationKey);
    await SecureStorage.delete(_addressSourceKey);
    await SecureStorage.delete(_activeSavedIdKey);
  }
}
