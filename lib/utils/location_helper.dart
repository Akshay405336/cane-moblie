import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // ===============================================================
  // SILENT CHECK (APP START / RESUME)
  // ❌ No permission dialog
  // ❌ No settings screen
  // ===============================================================

  static Future<bool> isReadySilently() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    return true;
  }

  // ===============================================================
  // USER-TRIGGERED FLOW (ENABLE BUTTON ONLY)
  // ✅ Can open permission dialog
  // ✅ Can open settings
  // ===============================================================

  static Future<bool> ensureLocationReady() async {
    // 1️⃣ Permission first (MOST IMPORTANT)
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

    // 2️⃣ GPS enabled?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  // ===============================================================
  // FETCH LIVE ADDRESS
  // ===============================================================

  static Future<String> fetchAddress() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;

    return [
      place.subLocality,
      place.locality,
      place.administrativeArea,
    ]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(', ');
  }

  // ===============================================================
  // BASIC GPS CHECK (OPTIONAL)
  // ===============================================================

  static Future<bool> isLocationEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
