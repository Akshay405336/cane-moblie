class Outlet {
  final String id;
  final String name;
  final String branch;

  final String status;

  final String workingStateStatus;

  final double latitude;
  final double longitude;

  final int deliveryRadiusKm;

  Outlet({
    required this.id,
    required this.name,
    required this.branch,
    required this.status,
    required this.workingStateStatus,
    required this.latitude,
    required this.longitude,
    required this.deliveryRadiusKm,
  });

  /* ================================================= */
  /* JSON                                               */
  /* ================================================= */

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'],
      name: json['name'],
      branch: json['branch'],
      status: json['status'],

      /// ⭐ map nested object correctly
      workingStateStatus:
          json['workingState']?['status'] ?? 'CLOSED',

      latitude: json['location']['latitude'] * 1.0,
      longitude: json['location']['longitude'] * 1.0,

      deliveryRadiusKm:
          json['deliveryRadiusKm'] ?? 5,
    );
  }

  /* ================================================= */
  /* CLEAN GETTER (for UI) ⭐                           */
  /* ================================================= */

  String get workingStatus => workingStateStatus;

  bool get isOpen => workingStateStatus == 'OPEN';
}
