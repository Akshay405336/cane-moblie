import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/location.model.dart';

/// ===============================================================
/// SERVICE
/// PURE ONLY:
/// - GPS
/// - Permission helpers
/// - Geocoding
/// NO state
/// NO UI
/// ===============================================================

class LocationService {
  LocationService._();

  /* =============================================================== */
  /* PERMISSION + SERVICE CHECKS                                     */
  /* =============================================================== */

  /// Silent check (no popup)
  static Future<bool> canUseLocationSilently() async {
    final permission = await Geolocator.checkPermission();
    final service = await Geolocator.isLocationServiceEnabled();

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever &&
        service;
  }

  /// Ask permission explicitly
  static Future<bool> requestPermission() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  /// Opens device settings
  static Future<void> openSettings() =>
      Geolocator.openLocationSettings();

  static Future<bool> isGpsEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /* =============================================================== */
  /* TEXT → COORDINATES                                              */
  /* =============================================================== */

  static Future<LocationData?> geocodeAddress(
    String address,
  ) async {
    try {
      final results = await locationFromAddress(address);
      if (results.isEmpty) return null;

      final loc = results.first;

      return LocationData(
        latitude: loc.latitude,
        longitude: loc.longitude,
        formattedAddress: address,
        source: AddressSource.manual,
      );
    } catch (_) {
      return null;
    }
  }

  /* =============================================================== */
  /* ⭐ GPS FETCH (MAIN METHOD USED BY CONTROLLER)                    */
  /* =============================================================== */

  static Future<LocationData?> fetchCurrentLocation() async {
    try {
      /// ⭐ DO NOT over-check here
      /// controller handles permission/service
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        forceAndroidLocationManager: true, // ⭐ IMPORTANT
        timeLimit: const Duration(seconds: 12),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place =
          placemarks.isNotEmpty ? placemarks.first : null;

      return _mapPlacemarkToLocation(position, place);
    } catch (_) {
      return null; // never crash
    }
  }

  /* =============================================================== */
  /* INTERNAL MAPPER                                                 */
  /* =============================================================== */

  static LocationData _mapPlacemarkToLocation(
    Position pos,
    Placemark? p,
  ) {
    final formatted = [
      p?.street,
      p?.subLocality,
      p?.locality,
      p?.administrativeArea,
      p?.postalCode,
    ]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(', ');

    return LocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      source: AddressSource.gps,

      house: p?.name,
      street: p?.street,
      area: p?.subLocality,
      landmark: p?.thoroughfare,
      city: p?.locality,
      state: p?.administrativeArea,
      pincode: p?.postalCode,
      country: p?.country,

      formattedAddress:
          formatted.isEmpty ? _fallback(pos) : formatted,
    );
  }

  static String _fallback(Position pos) {
    return 'Lat ${pos.latitude.toStringAsFixed(4)}, '
        'Lng ${pos.longitude.toStringAsFixed(4)}';
  }
}
