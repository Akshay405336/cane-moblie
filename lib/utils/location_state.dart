import 'secure_storage.dart';

enum AddressSource {
  gps,
  saved,
  manual,
}

class LocationState {
  LocationState._();

  /* ================================================= */
  /* STORAGE KEYS                                      */
  /* ================================================= */

  static const _locationKey = 'device_location_address';
  static const _addressSourceKey = 'active_address_source';
  static const _activeSavedIdKey = 'active_saved_address_id';

  // ⭐ coordinates (required for outlets API)
  static const _latKey = 'device_location_lat';
  static const _lngKey = 'device_location_lng';

  /* ================================================= */
  /* INTERNAL STATE                                    */
  /* ================================================= */

  static String? _address;
  static AddressSource? _source;
  static String? _activeSavedAddressId;

  static double? _latitude;
  static double? _longitude;

  static bool _isDetecting = false;
  static String? _errorMessage;

  /* ================================================= */
  /* GETTERS                                           */
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

  // ⭐ coordinates getters
  static double? get latitude => _latitude;
  static double? get longitude => _longitude;

  static bool get hasCoordinates =>
      _latitude != null && _longitude != null;

  /// 🔐 If true → do NOT auto fetch GPS
  static bool get hasPersistedLocation =>
      hasLocation && _source != null;

  /* ================================================= */
  /* LOAD PERSISTED STATE                              */
  /* ================================================= */

  static Future<void> load() async {
    final storedAddress = await SecureStorage.read(_locationKey);
    final storedSource = await SecureStorage.read(_addressSourceKey);
    final savedId = await SecureStorage.read(_activeSavedIdKey);

    final lat = await SecureStorage.read(_latKey);
    final lng = await SecureStorage.read(_lngKey);

    _address = storedAddress?.trim().isEmpty == true
        ? null
        : storedAddress;

    _latitude = lat != null ? double.tryParse(lat) : null;
    _longitude = lng != null ? double.tryParse(lng) : null;

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
  /* DETECTING STATE                                   */
  /* ================================================= */

  static void startDetecting() {
    _isDetecting = true;
    _errorMessage = null;
  }

  static void stopDetecting() {
    _isDetecting = false;
  }

  /* ================================================= */
  /* GPS FLOW                                          */
  /* ================================================= */

  static Future<void> setGpsAddress({
    required String address,
    required double lat,
    required double lng,
  }) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _latitude = lat;
    _longitude = lng;

    _source = AddressSource.gps;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'gps');
    await SecureStorage.delete(_activeSavedIdKey);

    await SecureStorage.write(_latKey, lat.toString());
    await SecureStorage.write(_lngKey, lng.toString());
  }

  /* ================================================= */
  /* MANUAL ADDRESS FLOW                               */
  /* ================================================= */

  static Future<void> setManualAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _latitude = null;
    _longitude = null;

    _source = AddressSource.manual;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'manual');
    await SecureStorage.delete(_activeSavedIdKey);

    await SecureStorage.delete(_latKey);
    await SecureStorage.delete(_lngKey);
  }

  /* ================================================= */
  /* SAVED ADDRESS FLOW                                */
  /* ================================================= */

  static Future<void> setSavedAddress({
    required String id,
    required String address,
    double? lat,
    double? lng,
  }) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    _address = trimmed;
    _latitude = lat;
    _longitude = lng;

    _source = AddressSource.saved;
    _activeSavedAddressId = id;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.write(_locationKey, trimmed);
    await SecureStorage.write(_addressSourceKey, 'saved');
    await SecureStorage.write(_activeSavedIdKey, id);

    if (lat != null) {
      await SecureStorage.write(_latKey, lat.toString());
    }

    if (lng != null) {
      await SecureStorage.write(_lngKey, lng.toString());
    }
  }

  /// ⭐ RESTORED (fixes your compile error)
  static Future<void> removeActiveSavedAddress() async {
    if (_source != AddressSource.saved) return;

    _address = null;
    _latitude = null;
    _longitude = null;
    _source = null;
    _activeSavedAddressId = null;
    _errorMessage = null;
    _isDetecting = false;

    await SecureStorage.delete(_locationKey);
    await SecureStorage.delete(_addressSourceKey);
    await SecureStorage.delete(_activeSavedIdKey);
    await SecureStorage.delete(_latKey);
    await SecureStorage.delete(_lngKey);
  }

  /* ================================================= */
  /* ERROR                                             */
  /* ================================================= */

  static void setError(String message) {
    _errorMessage = message;
    _isDetecting = false;
  }

  static void clearError() {
    _errorMessage = null;
  }

  /* ================================================= */
  /* CLEAR (FULL RESET ONLY)                           */
  /* ================================================= */

  static Future<void> clearAll() async {
    _address = null;
    _latitude = null;
    _longitude = null;
    _source = null;
    _activeSavedAddressId = null;
    _isDetecting = false;
    _errorMessage = null;

    await SecureStorage.delete(_locationKey);
    await SecureStorage.delete(_addressSourceKey);
    await SecureStorage.delete(_activeSavedIdKey);
    await SecureStorage.delete(_latKey);
    await SecureStorage.delete(_lngKey);
  }
}
