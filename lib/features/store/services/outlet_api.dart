import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/http_client.dart';
import '../models/product.model.dart';
import '../models/outlet.model.dart';

class OutletApi {
  OutletApi._();

  static final Dio _dio = AppHttpClient.dio;

  /* ================================================= */
  /* GET NEARBY OUTLETS                                */
  /* ================================================= */

  static Future<List<Outlet>> getNearby({
    required double lat,
    required double lng,
  }) async {
    try {
      debugPrint('🚚 GET /public/outlets?lat=$lat&lng=$lng');

      final response = await _dio.get(
        '/public/outlets',
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      final list =
          (response.data['data'] as List?) ?? const [];

      return list
          .map(
            (e) => Outlet.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e, s) {
      debugPrint('❌ OutletApi.getNearby → $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }

  /* ================================================= */
  /* GET OUTLET PRODUCTS                               */
  /* ================================================= */

  static Future<List<Product>> getOutletProducts(
    String outletId,
  ) async {
    try {
      debugPrint(
          '🛒 GET /public/outlets/$outletId/products');

      final response =
          await _dio.get('/public/outlets/$outletId/products');

      final list =
          (response.data['data'] as List?) ?? const [];

      return list
          .map(
            (e) => Product.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e, s) {
      debugPrint(
          '❌ OutletApi.getOutletProducts → $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }
}
