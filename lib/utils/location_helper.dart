import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// ===============================================================
/// DTO
/// ===============================================================
class CurrentLocationData {
  final String address;
  final double latitude;
  final double longitude;

  const CurrentLocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationHelper {
  LocationHelper._();

  /* =============================================================== */
  /* SILENT CHECK (no permission popup)                               */
  /* =============================================================== */

  static Future<bool> canUseLocationSilently() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return Geolocator.isLocationServiceEnabled();
  }

  /* =============================================================== */
  /* REQUEST PERMISSION (user triggered only)                         */
  /* =============================================================== */

  static Future<bool> requestPermissionFromUser() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  /* =============================================================== */
  /* ENSURE GPS SERVICE ENABLED                                       */
  /* =============================================================== */

  static Future<bool> ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (enabled) return true;

    await Geolocator.openLocationSettings();

    return Geolocator.isLocationServiceEnabled();
  }

  /* =============================================================== */
  /* ⭐ GEOCODE TEXT ADDRESS → COORDS                                  */
  /* =============================================================== */

  static Future<CurrentLocationData?> geocodeAddress(
    String address,
  ) async {
    try {
      final list = await locationFromAddress(address);

      if (list.isEmpty) return null;

      final loc = list.first;

      return CurrentLocationData(
        address: address,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  /* =============================================================== */
  /* ⭐ FETCH GPS LOCATION (ADDRESS + COORDS)                          */
  /* CALL ONLY AFTER USER PERMISSION + SERVICE OK                      */
  /* =============================================================== */

  static Future<CurrentLocationData?>
      fetchCurrentLocationData() async {
    try {
      final permission = await Geolocator.checkPermission();
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !serviceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // ⭐ better
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = '';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        address = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ]
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .join(', ');
      }

      // ⭐ fallback (never empty)
      if (address.isEmpty) {
        address =
            'Lat ${position.latitude.toStringAsFixed(4)}, '
            'Lng ${position.longitude.toStringAsFixed(4)}';
      }

      return CurrentLocationData(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null; // never crash
    }
  }

  /* =============================================================== */
  /* SIMPLE GPS CHECK (UI ONLY)                                       */
  /* =============================================================== */

  static Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}