class ProfileModel {
  final String id;
  final String customerId; // ⭐ Added customerId from new API
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dob;

  ProfileModel({
    required this.id,
    required this.customerId, // ⭐ Added to constructor
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.gender,
    this.dob,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle the 'data' wrapper if present, otherwise use the map directly
    final data = json.containsKey('data') ? json['data'] : json;

    return ProfileModel(
      id: data['id'] ?? '',
      customerId: data['customerId'] ?? '', // ⭐ Map customerId
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      gender: data['gender'],
      dob: data['dob'] != null ? DateTime.tryParse(data['dob']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dob': dob?.toIso8601String(), // ⭐ Backend expects full ISO string based on your logs
    };
  }
}