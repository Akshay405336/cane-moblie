import 'dart:io'; // ⭐ Added for File support
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

  /* ================================================= */
  /* LOAD PROFILE                                      */
  /* ================================================= */
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

  /* ================================================= */
  /* SAVE / UPDATE PROFILE                             */
  /* ================================================= */
  Future<void> saveProfile({
    required String fullName,
    required String email,
    String? gender,
    DateTime? dob,
    File? imageFile, // ⭐ Support for image selection from UI
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> fields = {
        'fullName': fullName,
        'email': email,
        'gender': gender,
        'dob': dob?.toIso8601String(),
      };

      ProfileModel updatedProfile;

      if (value == null) {
        // ⭐ Case 1: Create new profile (POST)
        // Note: Creating typically doesn't handle Multipart in your API logs,
        // but we use createProfile for initial setup.
        updatedProfile = await ProfileApi.createProfile(fields);
      } else {
        // ⭐ Case 2: Update existing profile (PATCH)
        updatedProfile = await ProfileApi.updateProfile(
          fields: fields,
          imageFile: imageFile,
        );
      }
      
      value = updatedProfile;
    } catch (e) {
      debugPrint("❌ Controller Save Error: $e");
      rethrow; // Pass error to UI for Snackbar
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /* ================================================= */
  /* DELETE PROFILE                                    */
  /* ================================================= */
  Future<void> deleteAccount() async {
    _loading = true;
    notifyListeners();

    try {
      final success = await ProfileApi.deleteProfile();
      if (success) {
        clear();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}