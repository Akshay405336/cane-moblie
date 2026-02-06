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
  /* COMMON REQUEST WRAPPER                            */
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
  /* GET CART (🔥 outletId REQUIRED)                   */
  /* ================================================= */

  static Future<Cart?> getCart({
    required String outletId,
  }) {
    debugPrint('🛒 GET /cart?outletId=$outletId');

    return _request(
      _dio.get(
        '/cart',
        queryParameters: {
          'outletId': outletId,
        },
      ),
    );
  }

  /* ================================================= */
  /* ADD ITEM (already correct)                        */
  /* ================================================= */

  static Future<Cart?> addItem({
    required String outletId,
    required String productId,
    int quantity = 1,
    bool forceReplace = false,
  }) {
    debugPrint('🛒 ADD item → $productId x$quantity');

    return _request(
      _dio.post(
        '/cart/items',
        data: {
          "outletId": outletId,
          "productId": productId,
          "quantity": quantity,
          "forceReplace": forceReplace,
        },
      ),
    );
  }

  /* ================================================= */
  /* UPDATE QTY (🔥 outletId REQUIRED)                 */
  /* ================================================= */

  static Future<Cart?> updateQty({
    required String outletId,
    required String productId,
    required int quantity,
  }) {
    debugPrint('🛒 UPDATE item → $productId → $quantity');

    return _request(
      _dio.patch(
        '/cart/items/$productId',
        queryParameters: {
          'outletId': outletId,
        },
        data: {
          "quantity": quantity,
        },
      ),
    );
  }

  /* ================================================= */
  /* REMOVE ITEM (🔥 outletId REQUIRED)                */
  /* ================================================= */

  static Future<Cart?> remove({
    required String outletId,
    required String productId,
  }) {
    debugPrint('🛒 REMOVE item → $productId');

    return _request(
      _dio.delete(
        '/cart/items/$productId',
        queryParameters: {
          'outletId': outletId,
        },
      ),
    );
  }

  /* ================================================= */
  /* CLEAR CART (🔥 outletId REQUIRED)                 */
  /* ================================================= */

  static Future<Cart?> clear({
    required String outletId,
  }) {
    debugPrint('🛒 CLEAR cart');

    return _request(
      _dio.delete(
        '/cart',
        queryParameters: {
          'outletId': outletId,
        },
      ),
    );
  }
}
