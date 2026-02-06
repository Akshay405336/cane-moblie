class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dob;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.gender,
    this.dob,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dob': dob?.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}