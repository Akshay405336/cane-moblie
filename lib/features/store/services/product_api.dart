import 'package:dio/dio.dart';
import '../../../core/network/http_client.dart';
import '../models/product.model.dart';
import 'package:flutter/foundation.dart';

class ProductApi {
  ProductApi._();

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

  static Future<List<Product>> getAllPublicProducts() async {
    try {
      debugPrint('🟡 PRODUCTS API → fetching all public products');

      final Response response = await AppHttpClient.dio.post(
        '/public/products',
      );

      final List data = response.data['data'] ?? [];
      
      return data.map((e) {
        return Product.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (e) {
      debugPrint('❌ API ERROR (getAllPublicProducts): $e');
      return [];
    }
  }
}