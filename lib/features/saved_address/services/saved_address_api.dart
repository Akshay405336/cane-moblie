import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/network/http_client.dart';
import '../models/saved_address.model.dart';

class SavedAddressApi {
  SavedAddressApi._();

  /// ⭐ use shared Dio (VERY IMPORTANT)
  static final Dio _dio = AppHttpClient.dio;

  static const String _base = '/saved-addresses';

  /* ================================================= */
  /* GET ALL                                           */
  /* ================================================= */

  static Future<List<SavedAddress>> getAll() async {
    try {
      final res = await _dio.get(_base);

      final List list = res.data['data'] ?? [];

      return list
          .map((e) => SavedAddress.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } catch (e) {
      debugPrint('❌ SavedAddressApi.getAll → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* GET BY ID                                         */
  /* ================================================= */

  static Future<SavedAddress> getById(String id) async {
    final res = await _dio.get('$_base/$id');
    return SavedAddress.fromJson(res.data['data']);
  }

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  static Future<SavedAddress> create(
    SavedAddress address,
  ) async {
    final res = await _dio.post(
      _base,
      data: address.toCreateJson(),
    );

    return SavedAddress.fromJson(res.data['data']);
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  static Future<SavedAddress> update(
    SavedAddress address,
  ) async {
    final res = await _dio.post(
      '$_base/${address.id}/update',
      data: address.toUpdateJson(),
    );

    return SavedAddress.fromJson(res.data['data']);
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  static Future<void> delete(String id) async {
    await _dio.post('$_base/$id/delete');
  }
}
