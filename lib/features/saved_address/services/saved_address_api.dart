import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/network/http_client.dart';
import '../models/saved_address.model.dart';

class SavedAddressApi {
  SavedAddressApi._();

  /// ⭐ shared Dio
  static final Dio _dio = AppHttpClient.dio;

  static const String _base = '/saved-addresses';

  /* ================================================= */
  /* GET ALL                                           */
  /* ================================================= */

  static Future<List<SavedAddress>> getAll() async {
    try {
      debugPrint('📡 API → GET $_base');

      final res = await _dio.get(_base);

      final list = (res.data?['data'] as List?) ?? [];

      final addresses = list
          .map((e) => SavedAddress.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      debugPrint('✅ fetched ${addresses.length} saved addresses');

      return addresses;
    } catch (e) {
      debugPrint('❌ SavedAddressApi.getAll → $e');
      throw _handleError(e);
    }
  }

  /* ================================================= */
  /* GET BY ID                                         */
  /* ================================================= */

  static Future<SavedAddress> getById(String id) async {
    try {
      debugPrint('📡 API → GET $_base/$id');

      final res = await _dio.get('$_base/$id');

      return SavedAddress.fromJson(res.data['data']);
    } catch (e) {
      debugPrint('❌ SavedAddressApi.getById → $e');
      throw _handleError(e);
    }
  }

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  static Future<SavedAddress> create(
    SavedAddress address,
  ) async {
    try {
      debugPrint('📡 API → CREATE address');

      final res = await _dio.post(
        _base,
        data: address.toCreateJson(),
      );

      // Check if backend returned success: false even with 200 OK
      if (res.data['success'] == false) {
        throw res.data['code'] ?? res.data['message'] ?? 'CREATE_FAILED';
      }

      final created =
          SavedAddress.fromJson(res.data['data']);

      debugPrint('✅ created → ${created.id}');

      return created;
    } catch (e) {
      debugPrint('❌ SavedAddressApi.create → $e');
      throw _handleError(e);
    }
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  static Future<SavedAddress> update(
    SavedAddress address,
  ) async {
    try {
      debugPrint('📡 API → UPDATE ${address.id}');

      final res = await _dio.post(
        '$_base/${address.id}/update',
        data: address.toUpdateJson(),
      );

      if (res.data['success'] == false) {
        throw res.data['code'] ?? res.data['message'] ?? 'UPDATE_FAILED';
      }

      final updated =
          SavedAddress.fromJson(res.data['data']);

      debugPrint('✅ updated → ${updated.id}');

      return updated;
    } catch (e) {
      debugPrint('❌ SavedAddressApi.update → $e');
      throw _handleError(e);
    }
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  static Future<void> delete(String id) async {
    try {
      debugPrint('📡 API → DELETE $id');

      final res = await _dio.post('$_base/$id/delete');

      if (res.data['success'] == false) {
        throw res.data['code'] ?? 'DELETE_FAILED';
      }

      debugPrint('✅ deleted → $id');
    } catch (e) {
      debugPrint('❌ SavedAddressApi.delete → $e');
      throw _handleError(e);
    }
  }

  /* ================================================= */
  /* ERROR HANDLER                                     */
  /* ================================================= */

  /// ⭐ Logic to extract the specific backend error code
  static dynamic _handleError(dynamic e) {
    if (e is DioException) {
      // If backend sends a response body with an error code
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('code')) {
        return responseData['code']; // e.g., 'SAVED_ADDRESS_TYPE_ALREADY_EXISTS'
      }
      return e.message ?? 'Network Error';
    }
    return e.toString();
  }
}