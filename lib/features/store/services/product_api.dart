import 'package:dio/dio.dart';
import '../../../core/network/http_client.dart';
import '../models/product.model.dart';
import 'package:flutter/foundation.dart';

class ProductApi {
  ProductApi._();

  /* ================================================= */
  /* GET OUTLET PRODUCTS                               */
  /* ================================================= */
  static Future<List<Product>> getByOutlet(String outletId) async {
    try {
      debugPrint('🟡 PRODUCTS API → fetching for outlet=$outletId');

      final Response response = await AppHttpClient.dio.get(
        '/public/outlets/$outletId/products',
      );

      final List data = response.data['data'] ?? [];
      
      return data.map((e) {
        final mapData = Map<String, dynamic>.from(e);
        
        // 🔥 DEBUG LOG: Confirming structural data
        if (mapData['category'] != null) {
          debugPrint('🎯 Found Category Map: ${mapData['category']}');
        }

        return Product.fromJson(mapData);
      }).toList();
    } catch (e) {
      debugPrint('❌ API ERROR (getByOutlet): $e');
      return [];
    }
  }

  /* ================================================= */
  /* GET ALL PUBLIC PRODUCTS                           */
  /* ================================================= */
  static Future<List<Product>> getAllPublicProducts() async {
    try {
      debugPrint('🟡 PRODUCTS API → fetching all public products');

      // 🔥 FIX: Changed from .post to .get to resolve the 404 error
      // Public data listings usually require GET requests.
      final Response response = await AppHttpClient.dio.get(
        '/public/products',
      );

      final List data = response.data['data'] ?? [];
      
      debugPrint('📦 PUBLIC DATA RECEIVED → count=${data.length}');

      return data.map((e) {
        return Product.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (e) {
      debugPrint('❌ API ERROR (getAllPublicProducts): $e');
      return [];
    }
  }
}