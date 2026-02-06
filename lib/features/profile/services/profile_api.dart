import 'package:flutter/foundation.dart';
import '../../../core/network/http_client.dart';
import '../models/profile.model.dart';

class ProfileApi {
  ProfileApi._();
  static final _dio = AppHttpClient.dio;

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

  static Future<ProfileModel> upsertProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/me/profile/upsert', data: data);
      return ProfileModel.fromJson(res.data['data']);
    } catch (e) {
      debugPrint("❌ Upsert Profile Error: $e");
      throw Exception('Failed to update profile');
    }
  }
}