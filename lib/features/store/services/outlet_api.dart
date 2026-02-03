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

      final body = response.data;

      if (body == null || body['data'] == null) {
        debugPrint('⚠️ Empty outlets response');
        return [];
      }

      final list =
          List<Map<String, dynamic>>.from(body['data']);

      final outlets = list
          .map(Outlet.fromJson)
          .toList();

      debugPrint(
          '✅ REST outlets parsed → count=${outlets.length}');

      return outlets;
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

      final body = response.data;

      if (body == null || body['data'] == null) {
        debugPrint('⚠️ Empty products response');
        return [];
      }

      final list =
          List<Map<String, dynamic>>.from(body['data']);

      final products = list
          .map(Product.fromJson)
          .toList();

      debugPrint(
          '✅ Products parsed → count=${products.length}');

      return products;
    } catch (e, s) {
      debugPrint(
          '❌ OutletApi.getOutletProducts → $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }
}
