import 'secure_storage.dart';

enum AddressSource {
  gps,
  saved,
  manual,
}

class LocationState {
  LocationState._();

  static const _locationKey = 'device_location_address';
  static const _addressSourceKey = 'active_address_source';
  static const _activeSavedIdKey = 'active_saved_address_id';

  static String? _address;
  static AddressSource? _source;
  static String? _activeSavedAddressId;

  // 🔄 Detecting state (for shimmer / loader)
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

  static AddressSource? get source => _source;

  static bool get isGpsAddress => _source == AddressSource.gps;
  static bool get isSavedAddress => _source == AddressSource.saved;
  static bool get isManualAddress => _source == AddressSource.manual;

  static String? get activeSavedAddressId => _activeSavedAddressId;

  static bool get isDetecting => _isDetecting;

  static bool get hasError => _errorMessage != null;

  static String get errorMessage =>
      _errorMessage ?? 'Unable to detect location';

  /// 🔐 HARD RULE:
  /// If true → NEVER auto-fetch GPS on app start
  static bool get hasPersistedLocation =>
      hasLocation && _source != null;

  /* ================================================= */
  /* LIFECYCLE                                        */
  /* ================================================= */

  /// Load persisted location
  /// 🚫 DOES NOT trigger GPS
  static Future<void> load() async {
    final storedAddress = await SecureStorage.read(_locationKey);
    final storedSource = await SecureStorage.read(_addressSourceKey);
    final savedId = await SecureStorage.read(_activeSavedIdKey);

    _address = storedAddress?.trim().isEmpty == true
        ? null
        : storedAddress;

    if (_address == null) {
      _source = null;
      _activeSavedAddressId = null;
      return;
    }

    switch (storedSource) {
      case 'gps':
        _source = AddressSource.gps;
        _activeSavedAddressId = null;
        break;
      case 'saved':
        _source = AddressSource.saved;
        _activeSavedAddressId = savedId;
        break;
      case 'manual':
        _source = AddressSource.manual;
        _activeSavedAddressId = null;
        break;
      default:
        _source = null;
        _activeSavedAddressId = null;
    }
  }

  /* ================================================= */
  /* GPS FLOW (USER-TRIGGERED ONLY)                    */
  /* ================================================= */

  /// Call ONLY when user taps "Use current location"
  static void startDetecting() {
    _isDetecting = true;
    _errorMessage = null;
  }

  static void stopDetecting() {
    _isDetecting = false;
  }

  /// ✅ The ONLY method allowed to set GPS address
  static Future<void> setGpsAddress(String value) async {
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
  /* MANUAL ADDRESS FLOW                              */
  /* ================================================= */

  static Future<void> setManualAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _source = AddressSource.manual;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'manual');
    await SecureStorage.delete(_activeSavedIdKey);
  }

  /* ================================================= */
  /* SAVED ADDRESS FLOW                               */
  /* ================================================= */

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

  /// Called only if active saved address is deleted
  static Future<void> removeActiveSavedAddress() async {
    if (_source != AddressSource.saved) return;

    _address = null;
    _source = null;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.delete(_locationKey);
    await SecureStorage.delete(_addressSourceKey);
    await SecureStorage.delete(_activeSavedIdKey);
  }

  /* ================================================= */
  /* ERROR                                            */
  /* ================================================= */

  static void setError(String message) {
    _errorMessage = message;
    _isDetecting = false;
  }

  static void clearError() {
    _errorMessage = null;
  }

  /* ================================================= */
  /* AUTH EVENTS                                      */
  /* ================================================= */

  /// 🔐 Logout MUST NOT clear location
  static Future<void> onLogout() async {
    // Intentionally empty
    // Location survives logout
  }

  /// 🚨 Full reset (manual app reset / debug only)
  static Future<void> clearAll() async {
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
