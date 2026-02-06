import 'package:flutter/material.dart';
import '../models/profile.model.dart';
import '../services/profile_api.dart';

class ProfileController extends ValueNotifier<ProfileModel?> {
  ProfileController._() : super(null);
  static final instance = ProfileController._();

  bool _loading = false;
  bool get isLoading => _loading;

  void clear() {
    value = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> load() async {
    if (_loading) return;
    
    _loading = true;
    notifyListeners(); // Notify UI to show shimmer/spinner

    try {
      final data = await ProfileApi.getProfile();
      value = data;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required String fullName,
    required String email,
    String? gender,
    DateTime? dob,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final updatedProfile = await ProfileApi.upsertProfile({
        'fullName': fullName,
        'email': email,
        'gender': gender,
        'dob': dob?.toIso8601String(), // Backend handles parsing
        // 'avatarUrl': ... (Add image upload logic later if needed)
      });
      
      value = updatedProfile;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}