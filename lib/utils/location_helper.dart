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

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    return serviceEnabled;
  }

  // ===============================================================
  // USER-TRIGGERED FLOW (BUTTON CLICK ONLY)
  // ✅ Can open permission dialog
  // ✅ Can open settings
  // ===============================================================

  static Future<bool> requestLocationAccessFromUser() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    if (permission == LocationPermission.denied) {
      return false;
    }

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  // ===============================================================
  // FETCH CURRENT ADDRESS
  // 🚨 CALL ONLY AFTER USER CLICK
  // ===============================================================

  static Future<String> fetchCurrentAddress() async {
    try {
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
          .where((e) => e != null && e!.isNotEmpty)
          .map((e) => e!)
          .join(', ');
    } catch (_) {
      // 🔐 Never crash location flow
      return '';
    }
  }

  // ===============================================================
  // SIMPLE GPS TOGGLE CHECK (UI USE ONLY)
  // ===============================================================

  static Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
