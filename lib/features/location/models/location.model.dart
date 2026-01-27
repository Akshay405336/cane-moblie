enum AddressSource {
  gps,
  saved,
  manual,
}

class LocationData {
  /* ================================================= */
  /* CORE                                              */
  /* ================================================= */

  final double? latitude;
  final double? longitude;
  final AddressSource source;

  /* ================================================= */
  /* STRUCTURED ADDRESS (Swiggy style)                 */
  /* ================================================= */

  final String? house;
  final String? street;
  final String? area;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  /* ================================================= */
  /* DISPLAY                                           */
  /* ================================================= */

  final String formattedAddress;

  /* ================================================= */
  /* EXTRA                                             */
  /* ================================================= */

  final String? savedAddressId;

  const LocationData({
    required this.formattedAddress,
    required this.source,
    this.latitude,
    this.longitude,
    this.house,
    this.street,
    this.area,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.savedAddressId,
  });

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  bool get hasCoordinates =>
      latitude != null && longitude != null;

  bool get isGps => source == AddressSource.gps;
  bool get isSaved => source == AddressSource.saved;
  bool get isManual => source == AddressSource.manual;

  bool get isEmpty => formattedAddress.trim().isEmpty;

  /// Header friendly
  String get displayAddress =>
      isEmpty ? 'Select location' : formattedAddress;

  /// Short header version
  String get shortAddress {
    final parts = [area, street, city]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();

    return parts.isEmpty ? displayAddress : parts.join(', ');
  }

  /// Full structured list (very useful later)
  List<String> get fullAddressParts => [
        house,
        street,
        area,
        landmark,
        city,
        state,
        pincode,
        country,
      ]
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();

  /* ================================================= */
  /* COPY                                              */
  /* ================================================= */

  LocationData copyWith({
    double? latitude,
    double? longitude,
    AddressSource? source,
    String? house,
    String? street,
    String? area,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? country,
    String? formattedAddress,
    String? savedAddressId,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      house: house ?? this.house,
      street: street ?? this.street,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      savedAddressId: savedAddressId ?? this.savedAddressId,
    );
  }

  /* ================================================= */
  /* FACTORIES                                         */
  /* ================================================= */

  factory LocationData.empty() {
    return const LocationData(
      formattedAddress: '',
      source: AddressSource.manual,
    );
  }

  /// ⭐ Helpful when building from GPS placemark later
  factory LocationData.fromParts({
    required String formatted,
    required double lat,
    required double lng,
    String? house,
    String? street,
    String? area,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) {
    return LocationData(
      formattedAddress: formatted,
      latitude: lat,
      longitude: lng,
      source: AddressSource.gps,
      house: house,
      street: street,
      area: area,
      landmark: landmark,
      city: city,
      state: state,
      pincode: pincode,
      country: country,
    );
  }

  /* ================================================= */
  /* JSON                                              */
  /* ================================================= */

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'source': source.name,
        'house': house,
        'street': street,
        'area': area,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'formattedAddress': formattedAddress,
        'savedAddressId': savedAddressId,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      source: AddressSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => AddressSource.manual,
      ),
      house: json['house'],
      street: json['street'],
      area: json['area'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      formattedAddress: json['formattedAddress'] ?? '',
      savedAddressId: json['savedAddressId'],
    );
  }

  @override
  String toString() =>
      'LocationData($formattedAddress | $latitude,$longitude | $source)';
}
