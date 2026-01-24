enum SavedAddressType {
  home,
  work,
  other,
}

class SavedAddress {
  final String id;
  final SavedAddressType type;
  final String label;
  final String address;

  // ⭐ NEW
  final double? lat;
  final double? lng;

  const SavedAddress({
    required this.id,
    required this.type,
    required this.label,
    required this.address,

    // ⭐ NEW
    this.lat,
    this.lng,
  });

  // ------------------------------
  // COPY (FOR EDIT FLOW)
  // ------------------------------

  SavedAddress copyWith({
    String? label,
    String? address,
    SavedAddressType? type,

    // ⭐ NEW
    double? lat,
    double? lng,
  }) {
    return SavedAddress(
      id: id,
      type: type ?? this.type,
      label: label ?? this.label,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  // ------------------------------
  // UI HELPERS
  // ------------------------------

  bool isActive(String? activeSavedAddressId) {
    return activeSavedAddressId != null &&
        activeSavedAddressId == id;
  }

  // ------------------------------
  // SERIALIZATION
  // ------------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'label': label,
        'address': address,

        // ⭐ NEW
        'lat': lat,
        'lng': lng,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'];

    final resolvedType = SavedAddressType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => SavedAddressType.other,
    );

    return SavedAddress(
      id: json['id']?.toString() ?? '',
      type: resolvedType,
      label: json['label']?.toString() ?? '',
      address: json['address']?.toString() ?? '',

      // ⭐ NEW
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  // ------------------------------
  // EQUALITY
  // ------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedAddress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
