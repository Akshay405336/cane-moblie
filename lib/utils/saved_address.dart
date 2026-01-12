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

  const SavedAddress({
    required this.id,
    required this.type,
    required this.label,
    required this.address,
  });

  // ------------------------------
  // COPY (FOR EDIT FLOW)
  // ------------------------------

  SavedAddress copyWith({
    String? label,
    String? address,
  }) {
    return SavedAddress(
      id: id,
      type: type,
      label: label ?? this.label,
      address: address ?? this.address,
    );
  }

  // ------------------------------
  // UI HELPER (OPTIONAL)
  // ------------------------------

  /// Useful for highlighting selected address in UI
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
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'],
      type: SavedAddressType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      label: json['label'],
      address: json['address'],
    );
  }
}
