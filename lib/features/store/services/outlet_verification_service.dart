import 'package:geolocator/geolocator.dart';
import '../../location/models/location.model.dart';

class OutletVerificationService {
  /// Maximum delivery distance in Kilometers
  static const double maxDeliveryDistance = 6.0;

  /// Returns true if the address is within range of the outlet
  static bool isWithinRange({
    required LocationData address,
    required String? currentOutletLat,
    required String? currentOutletLng,
  }) {
    if (address.latitude == null || address.longitude == null) return false;
    if (currentOutletLat == null || currentOutletLng == null) return false;

    final double outletLat = double.tryParse(currentOutletLat) ?? 0;
    final double outletLng = double.tryParse(currentOutletLng) ?? 0;

    // Calculate distance using Geolocator
    double distanceInMeters = Geolocator.distanceBetween(
      address.latitude!,
      address.longitude!,
      outletLat,
      outletLng,
    );

    double distanceInKm = distanceInMeters / 1000;
    return distanceInKm <= maxDeliveryDistance;
  }
}