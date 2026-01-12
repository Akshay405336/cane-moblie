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
    if (!serviceEnabled) return false;

    return true;
  }

  // ===============================================================
  // USER-TRIGGERED FLOW (BUTTON CLICK ONLY)
  // ✅ Can open permission dialog
  // ✅ Can open settings
  // ===============================================================

  static Future<bool> requestLocationAccessFromUser() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    // Ask permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permanently denied
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    // Still denied
    if (permission == LocationPermission.denied) {
      return false;
    }

    // GPS service ON?
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
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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
  }

  // ===============================================================
  // SIMPLE GPS TOGGLE CHECK (UI USE ONLY)
  // ===============================================================

  static Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
