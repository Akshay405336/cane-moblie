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
      rethrow;
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
      rethrow;
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

      final created =
          SavedAddress.fromJson(res.data['data']);

      debugPrint('✅ created → ${created.id}');

      return created;
    } catch (e) {
      debugPrint('❌ SavedAddressApi.create → $e');
      rethrow;
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

      final updated =
          SavedAddress.fromJson(res.data['data']);

      debugPrint('✅ updated → ${updated.id}');

      return updated;
    } catch (e) {
      debugPrint('❌ SavedAddressApi.update → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  static Future<void> delete(String id) async {
    try {
      debugPrint('📡 API → DELETE $id');

      await _dio.post('$_base/$id/delete');

      debugPrint('✅ deleted → $id');
    } catch (e) {
      debugPrint('❌ SavedAddressApi.delete → $e');
      rethrow;
    }
  }
}
