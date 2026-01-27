import 'package:flutter/foundation.dart';
import '../../../core/network/http_client.dart';
import '../models/cart.model.dart';

class CartApi {
  CartApi._();

  static final _dio = AppHttpClient.dio;

  /* ================================================= */
  /* SAFE RESPONSE PARSER                              */
  /* ================================================= */

  static Cart? _parseResponse(dynamic responseData) {
    try {
      if (responseData == null) return null;

      final map = Map<String, dynamic>.from(responseData);
      return Cart.fromJson(map);
    } catch (e) {
      debugPrint('❌ Cart parse failed → $e');
      return null;
    }
  }

  /* ================================================= */
  /* COMMON REQUEST WRAPPER (DRY + SAFE)               */
  /* ================================================= */

  static Future<Cart?> _request(Future<dynamic> call) async {
    try {
      final res = await call;

      final data =
          (res.data is Map<String, dynamic>) ? res.data['data'] : null;

      return _parseResponse(data);
    } catch (e) {
      debugPrint('❌ CartApi request failed → $e');
      return null;
    }
  }

  /* ================================================= */
  /* GET CART                                          */
  /* ================================================= */

  static Future<Cart?> getCart() {
    debugPrint('🛒 GET /cart');

    return _request(
      _dio.get('/cart'),
    );
  }

  /* ================================================= */
  /* ADD ITEM                                          */
  /* ================================================= */

  static Future<Cart?> addItem({
    required String outletId,
    required String productId,
    int quantity = 1,
  }) {
    debugPrint('🛒 ADD item → $productId x$quantity');

    return _request(
      _dio.post(
        '/cart/items',
        data: {
          "outletId": outletId,
          "productId": productId,
          "quantity": quantity,
        },
      ),
    );
  }

  /* ================================================= */
  /* UPDATE QTY                                        */
  /* ================================================= */

  static Future<Cart?> updateQty({
    required String productId,
    required int quantity,
  }) {
    debugPrint('🛒 UPDATE item → $productId → $quantity');

    return _request(
      _dio.patch(
        '/cart/items/$productId',
        data: {
          "quantity": quantity,
        },
      ),
    );
  }

  /* ================================================= */
  /* REMOVE ITEM                                       */
  /* ================================================= */

  static Future<Cart?> remove(String productId) {
    debugPrint('🛒 REMOVE item → $productId');

    return _request(
      _dio.delete('/cart/items/$productId'),
    );
  }

  /* ================================================= */
  /* CLEAR CART                                        */
  /* ================================================= */

  static Future<Cart?> clear() {
    debugPrint('🛒 CLEAR cart');

    return _request(
      _dio.delete('/cart'),
    );
  }
}
