import 'package:dio/dio.dart';
import '../../../core/network/http_client.dart';
import '../models/product.model.dart';
import 'package:flutter/foundation.dart';

class ProductApi {
  ProductApi._();

  /* ================================================= */
  /* GET OUTLET PRODUCTS                               */
  /* ================================================= */

  static Future<List<Product>> getByOutlet(
    String outletId,
  ) async {
    debugPrint('🟡 PRODUCTS API → fetching for outlet=$outletId');

    final Response response =
        await AppHttpClient.dio.get(
      '/public/outlets/$outletId/products',
    );

    debugPrint('📦 RAW RESPONSE => ${response.data}');

    final List data = response.data['data'] ?? [];

    debugPrint('📦 DATA LENGTH => ${data.length}');

    final products = data
        .map(
          (e) => Product.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    debugPrint('✅ PARSED PRODUCTS => ${products.length}');

    return products;
  }
}
