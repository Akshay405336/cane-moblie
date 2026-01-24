import 'package:dio/dio.dart';

import '../../../network/http_client.dart';
import '../../../utils/api_error_handler.dart';
import '../../../utils/app_toast.dart';

class SavedAddressApi {
  SavedAddressApi._();

  /* ================================================= */
  /* GET ALL SAVED ADDRESSES                           */
  /* ================================================= */

  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response =
          await AppHttpClient.dio.get('/saved-addresses');

      return List<Map<String, dynamic>>.from(
        response.data['data'] ?? [],
      );
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return [];
    }
  }

  /* ================================================= */
  /* CREATE SAVED ADDRESS                              */
  /* ================================================= */

  static Future<Map<String, dynamic>?> create({
    required String type,
    required String label,
    required String addressText,

    // ⭐ NEW
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response =
          await AppHttpClient.dio.post(
        '/saved-addresses',
        data: {
          'type': type.toUpperCase(),
          'label': label,
          'addressText': addressText,

          // ⭐ NEW
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return response.data['data'];
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return null;
    }
  }

  /* ================================================= */
  /* UPDATE SAVED ADDRESS                              */
  /* ================================================= */

  static Future<Map<String, dynamic>?> update({
    required String id,
    required String addressText,

    // ⭐ NEW
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response =
          await AppHttpClient.dio.post(
        '/saved-addresses/$id/update',
        data: {
          'addressText': addressText,

          // ⭐ NEW
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return response.data['data'];
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return null;
    }
  }

  /* ================================================= */
  /* DELETE SAVED ADDRESS                              */
  /* ================================================= */

  static Future<bool> delete(String id) async {
    try {
      await AppHttpClient.dio.post(
        '/saved-addresses/$id/delete',
      );
      return true;
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return false;
    }
  }
}
