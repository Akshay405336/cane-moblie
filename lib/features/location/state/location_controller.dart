import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location.model.dart';
import '../services/location_service.dart';
import '../../../core/storage/secure_storage.dart';

class LocationController extends ChangeNotifier {
  /* ================================================= */
  /* STORAGE                                           */
  /* ================================================= */

  static const _cacheKey = 'cached_location_data';

  /* ================================================= */
  /* STATE                                             */
  /* ================================================= */

  LocationData? _current;
  bool _isDetecting = false;
  String? _error;

  LocationData? get current => _current;

  bool get hasLocation =>
      _current != null && !_current!.isEmpty;

  bool get isDetecting => _isDetecting;

  String? get error => _error;

  /* ================================================= */
  /* LOAD (SMART CACHE)                                */
  /* ================================================= */

  Future<void> load() async {
    debugPrint('📦 Controller → load cache');

    final gpsEnabled =
        await Geolocator.isLocationServiceEnabled();

    /// ⭐ FIX: MUST notify when clearing
    if (!gpsEnabled) {
      debugPrint('⚠️ GPS OFF → clearing cached location');

      await SecureStorage.delete(_cacheKey);

      _current = null;

      notifyListeners(); // ⭐ IMPORTANT FIX

      return;
    }

    final json = await SecureStorage.readJson(_cacheKey);

    if (json == null) {
      debugPrint('📦 No cached location');
      return;
    }

    _current = LocationData.fromJson(json);

    debugPrint('✅ Cache loaded → ${_current!.formattedAddress}');

    _locationUpdated();
  }

  /* ================================================= */
  /* DETECT CURRENT LOCATION                           */
  /* ================================================= */

  Future<void> detectCurrentLocation() async {
    if (_isDetecting) {
      debugPrint('⛔ detect skipped (already running)');
      return;
    }

    debugPrint('🚀 Controller → detectCurrentLocation()');

    _isDetecting = true;
    _error = null;
    _locationUpdated();

    try {
      final hasPermission =
          await LocationService.requestPermission();

      if (!hasPermission) {
        _error = 'Location permission required';
        return;
      }

      var gpsEnabled =
          await LocationService.isGpsEnabled();

      if (!gpsEnabled) {
        await LocationService.openSettings();

        await Future.delayed(
          const Duration(milliseconds: 700),
        );

        gpsEnabled =
            await LocationService.isGpsEnabled();

        if (!gpsEnabled) {
          _error = 'Turn on location services';
          return;
        }
      }

      final result =
          await LocationService.fetchCurrentLocation();

      if (result == null) {
        _error = 'Unable to detect location';
        return;
      }

      _current = result;

      debugPrint(
          '✅ Location detected → ${result.formattedAddress}');

      await _persist();
    } catch (e) {
      debugPrint('❌ Detect crash → $e');
      _error = e.toString();
    } finally {
      _isDetecting = false;
      _locationUpdated();
    }
  }

  /* ================================================= */
  /* MANUAL SEARCH                                     */
  /* ================================================= */

  Future<void> setManual(String address) async {
    debugPrint('✍️ Manual set → $address');

    final result =
        await LocationService.geocodeAddress(address);

    if (result == null) return;

    _current = result;

    await _persist();

    _locationUpdated();
  }

  /* ================================================= */
  /* SAVED ADDRESS                                     */
  /* ================================================= */

  Future<void> setSaved(LocationData saved) async {
    debugPrint('🏠 Saved selected → ${saved.formattedAddress}');

    _current = saved.copyWith(
      source: AddressSource.saved,
    );

    await _persist();

    _locationUpdated(); // ⭐ triggers header + home refresh
  }

  /* ================================================= */
  /* CLEAR                                             */
  /* ================================================= */

  Future<void> clear() async {
    debugPrint('🗑 Clearing location');

    _current = null;

    await SecureStorage.delete(_cacheKey);

    notifyListeners();
  }

  /* ================================================= */
  /* PERSIST                                           */
  /* ================================================= */

  Future<void> _persist() async {
    if (_current == null) return;

    await SecureStorage.writeJson(
      _cacheKey,
      _current!.toJson(),
    );

    debugPrint('💾 Location persisted');
  }

  /* ================================================= */
  /* INTERNAL                                          */
  /* ================================================= */

  void _locationUpdated() {
    debugPrint('📡 Location updated → notify UI');
    notifyListeners();
  }
}
