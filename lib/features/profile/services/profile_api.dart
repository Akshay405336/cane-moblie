import 'dart:io'; // ⭐ Required for File
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/http_client.dart';
import '../models/profile.model.dart';

class ProfileApi {
  ProfileApi._();
  static final _dio = AppHttpClient.dio;

  /* ================================================= */
  /* GET PROFILE                                       */
  /* ================================================= */
  static Future<ProfileModel?> getProfile() async {
    try {
      final res = await _dio.get('/me/profile');
      if (res.data['data'] != null) {
        return ProfileModel.fromJson(res.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Get Profile Error: $e");
      return null;
    }
  }

  /* ================================================= */
  /* CREATE PROFILE (POST)                             */
  /* ================================================= */
  static Future<ProfileModel> createProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/me/profile', data: data);
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      debugPrint("❌ Create Profile Error: $e");
      throw Exception('Failed to create profile');
    }
  }

  /* ================================================= */
  /* UPDATE PROFILE (PATCH with Image Upload support)  */
  /* ================================================= */
  static Future<ProfileModel> updateProfile({
    required Map<String, dynamic> fields,
    File? imageFile, // ⭐ Support for Avatar Upload
  }) async {
    try {
      // Use FormData if there's an image, otherwise normal JSON
      dynamic requestData;

      if (imageFile != null) {
        requestData = FormData.fromMap({
          ...fields,
          'avatar': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        });
      } else {
        requestData = fields;
      }

      final res = await _dio.patch('/me/profile', data: requestData);
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      debugPrint("❌ Update Profile Error: $e");
      throw Exception('Failed to update profile');
    }
  }

  /* ================================================= */
  /* DELETE PROFILE                                    */
  /* ================================================= */
  static Future<bool> deleteProfile() async {
    try {
      final res = await _dio.delete('/me/profile');
      return res.data['success'] == true;
    } catch (e) {
      debugPrint("❌ Delete Profile Error: $e");
      return false;
    }
  }
}