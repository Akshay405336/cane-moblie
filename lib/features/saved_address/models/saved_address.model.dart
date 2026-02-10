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
      case 'OTHER':
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
  final String address; // Mapped from addressText
  final double? lat;     // Mapped from latitude
  final double? lng;     // Mapped from longitude
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
  /* HELPERS                                                         */
  /* =============================================================== */

  bool get hasCoordinates => lat != null && lng != null;

  bool get isValid => address.trim().isNotEmpty && !isDeleted;

  String get displayLabel =>
      label.trim().isEmpty ? 'Address' : label;

  String get shortAddress {
    final text = address.trim();
    if (text.length <= 40) return text;
    return '${text.substring(0, 40)}...';
  }

  /* =============================================================== */
  /* ⭐ BRIDGE → LOCATION SYSTEM                                      */
  /* =============================================================== */

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
  /* COPY                                                            */
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
  /* JSON                                                            */
  /* =============================================================== */

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      type: SavedAddressType.fromApi(json['type'] ?? 'OTHER'),
      label: json['label'] ?? '',
      address: json['addressText'] ?? '', // Backend uses addressText
      lat: (json['latitude'] as num?)?.toDouble(), // Backend uses latitude
      lng: (json['longitude'] as num?)?.toDouble(), // Backend uses longitude
      isDeleted: json['isDeleted'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// ⭐ create payload (Exactly matches backend POST body)
  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.toApi(),
      'label': label,
      'addressText': address,
      'latitude': lat,
      'longitude': lng,
    };
  }

  /// ⭐ update payload (Matches backend requirements)
  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.toApi(),
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

  @override
  String toString() {
    return 'SavedAddress($label → $address | $lat,$lng)';
  }
}

/// Helper class to handle the Backend Response Wrapper
class AddressApiResponse {
  final bool success;
  final String code;
  final String message;
  final dynamic data;

  AddressApiResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory AddressApiResponse.fromJson(Map<String, dynamic> json) {
    return AddressApiResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  // Helper to check for the specific singleton error you received
  bool get isDuplicateType => code == "SAVED_ADDRESS_TYPE_ALREADY_EXISTS";
}