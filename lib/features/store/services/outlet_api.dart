import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../network/http_client.dart';
import '../../../utils/location_state.dart';
import '../models/product.model.dart';
import '../models/outlet.model.dart';

class OutletApi {
  OutletApi._();

  /* ================================================= */
  /* GET NEARBY OUTLETS                                */
  /* ================================================= */

  static Future<List<Outlet>> getNearby({
    required double lat,
    required double lng,
  }) async {
    try {
      debugPrint(
        '🚚 REST → Fetch outlets with lat=$lat, lng=$lng',
      );

      final Response response =
          await AppHttpClient.dio.get(
        '/public/outlets',
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      final List data = response.data['data'] ?? [];

      final outlets = data
          .map(
            (e) => Outlet.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      debugPrint(
        '📦 REST → Outlets received: ${outlets.length}',
      );

      return outlets;
    } catch (e) {
      debugPrint('❌ OutletApi.getNearby error => $e');
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
        '🛒 REST → Fetch products for outlet=$outletId',
      );

      final Response response =
          await AppHttpClient.dio.get(
        '/public/outlets/$outletId/products',
      );

      final List data = response.data['data'] ?? [];

      final products = data
          .map(
            (e) => Product.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      debugPrint(
        '📦 Products received: ${products.length}',
      );

      return products;
    } catch (e) {
      debugPrint(
          '❌ OutletApi.getOutletProducts error => $e');
      return [];
    }
  }
}
