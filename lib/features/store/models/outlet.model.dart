class Outlet {
  final String id;
  final String name;
  final String branch;

  final String status;
  final String workingStateStatus;

  final double latitude;
  final double longitude;

  final int deliveryRadiusKm;

  /// ⭐ optional (backend already sends it)
  final double? distanceKm;

  const Outlet({
    required this.id,
    required this.name,
    required this.branch,
    required this.status,
    required this.workingStateStatus,
    required this.latitude,
    required this.longitude,
    required this.deliveryRadiusKm,
    this.distanceKm,
  });

  /* ================================================= */
  /* JSON (SAFE + DEFENSIVE) ⭐                         */
  /* ================================================= */

  factory Outlet.fromJson(Map<String, dynamic> json) {
    final location =
        (json['location'] as Map?)?.cast<String, dynamic>() ?? {};

    final workingState =
        (json['workingState'] as Map?)?.cast<String, dynamic>() ?? {};

    return Outlet(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      branch: json['branch'] ?? '',
      status: json['status'] ?? 'UNKNOWN',

      workingStateStatus:
          workingState['status'] ?? 'CLOSED',

      latitude: (location['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0,

      deliveryRadiusKm:
          (json['deliveryRadiusKm'] as num?)?.toInt() ?? 5,

      distanceKm:
          (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  /* ================================================= */
  /* CLEAN GETTERS                                     */
  /* ================================================= */

  String get workingStatus => workingStateStatus;

  bool get isOpen =>
      workingStateStatus.toUpperCase() == 'OPEN';

  bool get hasDistance => distanceKm != null;

  String get distanceLabel =>
      distanceKm == null ? '' : '${distanceKm!.toStringAsFixed(2)} km';
}
