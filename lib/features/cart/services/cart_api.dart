import 'package:flutter/foundation.dart';
import '../../../core/network/http_client.dart';
import '../models/cart.model.dart';

class CartApi {
  CartApi._();

  static final _dio = AppHttpClient.dio;

  /* ================================================= */
  /* SAFE PARSER                                       */
  /* ================================================= */

  static Cart? _parse(dynamic data) {
    if (data == null) return null;
    return Cart.fromJson(Map<String, dynamic>.from(data));
  }

  /* ================================================= */
  /* GET CART                                          */
  /* ================================================= */

  static Future<Cart?> getCart() async {
    try {
      debugPrint('🛒 GET /cart');

      final res = await _dio.get('/cart');

      return _parse(res.data['data']);
    } catch (e) {
      debugPrint('❌ CartApi.getCart → $e');
      return null;
    }
  }

  /* ================================================= */
  /* ADD ITEM                                          */
  /* ================================================= */

  static Future<Cart?> addItem({
    required String outletId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      debugPrint('🛒 ADD item → $productId x$quantity');

      final res = await _dio.post(
        '/cart/items',
        data: {
          "outletId": outletId,
          "productId": productId,
          "quantity": quantity,
        },
      );

      return _parse(res.data['data']);
    } catch (e) {
      debugPrint('❌ CartApi.addItem → $e');
      return null;
    }
  }

  /* ================================================= */
  /* UPDATE QTY                                        */
  /* ================================================= */

  static Future<Cart?> updateQty({
    required String productId,
    required int quantity,
  }) async {
    try {
      debugPrint('🛒 UPDATE item → $productId → $quantity');

      final res = await _dio.patch(
        '/cart/items/$productId',
        data: {
          "quantity": quantity,
        },
      );

      return _parse(res.data['data']);
    } catch (e) {
      debugPrint('❌ CartApi.updateQty → $e');
      return null;
    }
  }

  /* ================================================= */
  /* REMOVE ITEM                                       */
  /* ================================================= */

  static Future<Cart?> remove(String productId) async {
    try {
      debugPrint('🛒 REMOVE item → $productId');

      final res = await _dio.delete('/cart/items/$productId');

      return _parse(res.data['data']);
    } catch (e) {
      debugPrint('❌ CartApi.remove → $e');
      return null;
    }
  }

  /* ================================================= */
  /* CLEAR CART                                        */
  /* ================================================= */

  static Future<Cart?> clear() async {
    try {
      debugPrint('🛒 CLEAR cart');

      final res = await _dio.delete('/cart');

      return _parse(res.data['data']);
    } catch (e) {
      debugPrint('❌ CartApi.clear → $e');
      return null;
    }
  }
}
