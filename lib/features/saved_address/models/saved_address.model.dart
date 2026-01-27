
import '../../location/models/location.model.dart';


enum SavedAddressType {
  home,
  work,
  other;

  /* ================= BACKEND MAPPING ================= */

  static SavedAddressType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'HOME':
        return SavedAddressType.home;
      case 'WORK':
        return SavedAddressType.work;
      default:
        return SavedAddressType.other;
    }
  }

  String toApi() {
    switch (this) {
      case SavedAddressType.home:
        return 'HOME';
      case SavedAddressType.work:
        return 'WORK';
      case SavedAddressType.other:
        return 'OTHER';
    }
  }

  /// ⭐ UI helper
  String get displayName {
    switch (this) {
      case SavedAddressType.home:
        return 'Home';
      case SavedAddressType.work:
        return 'Work';
      case SavedAddressType.other:
        return 'Other';
    }
  }
}

class SavedAddress {
  final String id;
  final String customerId;

  final SavedAddressType type;
  final String label;
  final String address;

  final double? lat;
  final double? lng;

  final bool isDeleted;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedAddress({
    required this.id,
    required this.customerId,
    required this.type,
    required this.label,
    required this.address,
    this.lat,
    this.lng,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /* =============================================================== */
  /* HELPERS                                                          */
  /* =============================================================== */

  /// GPS available?
  bool get hasCoordinates => lat != null && lng != null;

  /// Safe usable?
  bool get isValid => address.trim().isNotEmpty && !isDeleted;

  /// UI fallback
  String get displayLabel => label.isEmpty ? 'Address' : label;

  /// shorter version for tiles/headers
  String get shortAddress {
    if (address.length <= 40) return address;
    return '${address.substring(0, 40)}...';
  }

  /* =============================================================== */
  /* ⭐ MOST IMPORTANT (bridge to Location system)                     */
  /* =============================================================== */

  /// Convert directly → LocationData
  /// So UI/Controller never manually map fields
  LocationData toLocationData() {
    return LocationData(
      latitude: lat,
      longitude: lng,
      source: AddressSource.saved,
      formattedAddress: address,
      savedAddressId: id,
    );
  }

  /* =============================================================== */
  /* COPY                                                             */
  /* =============================================================== */

  SavedAddress copyWith({
    String? id,
    String? customerId,
    SavedAddressType? type,
    String? label,
    String? address,
    double? lat,
    double? lng,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      label: label ?? this.label,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /* =============================================================== */
  /* JSON                                                             */
  /* =============================================================== */

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      type: SavedAddressType.fromApi(json['type'] ?? 'OTHER'),
      label: json['label'] ?? '',
      address: json['addressText'] ?? '',
      lat: (json['latitude'] as num?)?.toDouble(),
      lng: (json['longitude'] as num?)?.toDouble(),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.toApi(),
      'label': label,
      'addressText': address,
      'latitude': lat,
      'longitude': lng,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'label': label,
      'addressText': address,
      'latitude': lat,
      'longitude': lng,
    };
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  /* =============================================================== */
  /* DEBUG                                                            */
  /* =============================================================== */

  @override
  String toString() {
    return 'SavedAddress($label → $address | $lat,$lng)';
  }
}
