import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  LocationHelper._();

  // ===============================================================
  // SILENT CHECK (APP START / RESUME)
  // ❌ No permission dialog
  // ❌ No settings screen
  // ❌ NO GPS FETCH
  // ===============================================================

  static Future<bool> canUseLocationSilently() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return Geolocator.isLocationServiceEnabled();
  }

  // ===============================================================
  // USER-TRIGGERED PERMISSION FLOW (BUTTON CLICK ONLY)
  // ✅ Permission dialog allowed
  // ❌ NO GPS FETCH
  // ===============================================================

  static Future<bool> requestPermissionFromUser() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // ===============================================================
  // USER-TRIGGERED SERVICE ENABLE FLOW
  // ✅ Opens system location settings
  // ===============================================================

  static Future<bool> ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (enabled) return true;

    await Geolocator.openLocationSettings();

    // Re-check after returning from settings
    return Geolocator.isLocationServiceEnabled();
  }

  // ===============================================================
  // FETCH CURRENT ADDRESS
  // 🚨 CALL ONLY AFTER USER CLICK + PERMISSION + SERVICE OK
  // ===============================================================

  static Future<String> fetchCurrentAddress() async {
    try {
      final permission = await Geolocator.checkPermission();
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !serviceEnabled) {
        return '';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return '';

      final place = placemarks.first;

      return [
        place.subLocality,
        place.locality,
        place.administrativeArea,
      ]
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .join(', ');
    } catch (_) {
      // 🔐 Never crash location flow
      return '';
    }
  }

  // ===============================================================
  // SIMPLE GPS SERVICE CHECK (UI ONLY)
  // ===============================================================

  static Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
