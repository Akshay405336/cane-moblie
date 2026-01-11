import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  /// Step 1: Ensure GPS + permission
  static Future<void> ensureLocationReady() async {
    // 1️⃣ GPS ON?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // 2️⃣ Permission
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 3️⃣ Permanently denied
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }
  }

  /// Step 2: Get address
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
      place.administrativeArea
    ].where((e) => e != null && e!.isNotEmpty).join(', ');
  }
}
