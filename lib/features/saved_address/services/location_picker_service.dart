import 'package:geocoding/geocoding.dart';

class LocationPickerService {
  LocationPickerService._();

  static Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final places = await placemarkFromCoordinates(lat, lng);

    if (places.isEmpty) return '';

    final p = places.first;

    return [
      p.name,
      p.street,
      p.locality,
      p.administrativeArea,
      p.postalCode,
    ].where((e) => e != null && e!.isNotEmpty).join(', ');
  }
}
