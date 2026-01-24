import 'package:flutter/foundation.dart';

import '../models/product.model.dart';
import '../services/product_api.dart';

/// ✅ REST ONLY (NO SOCKET)
/// ------------------------------------------------
/// Backend does not provide products websocket.
/// So we fetch via HTTP and cache locally.
class ProductSocketService {
  ProductSocketService._();

  static final List<void Function(List<Product>)> _listeners = [];

  static List<Product> _cachedProducts = [];

  /* ================================================= */
  /* FETCH (REST) ⭐ REPLACED SOCKET                    */
  /* ================================================= */

  static Future<void> connect(String outletId) async {
    debugPrint('🛒 PRODUCT → fetching products (REST) outlet=$outletId');

    try {
      final products = await ProductApi.getByOutlet(outletId);

      _cachedProducts = products;

      debugPrint(
        '🛒 PRODUCT → fetched ${products.length} products',
      );

      /// notify listeners
      for (final listener in _listeners) {
        listener(products);
      }
    } catch (e) {
      debugPrint('❌ PRODUCT → fetch failed $e');
    }
  }

  /* ================================================= */
  /* SUBSCRIBE                                          */
  /* ================================================= */

  static void subscribe(
    void Function(List<Product>) listener,
  ) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }

    /// instant replay
    if (_cachedProducts.isNotEmpty) {
      listener(_cachedProducts);
    }
  }

  static void unsubscribe(
    void Function(List<Product>) listener,
  ) {
    _listeners.remove(listener);
  }

  /* ================================================= */
  /* CACHE                                              */
  /* ================================================= */

  static List<Product> get cachedProducts => _cachedProducts;

  /* ================================================= */
  /* DISCONNECT (now just clears cache)                */
  /* ================================================= */

  static void disconnect() {
    _listeners.clear();
    _cachedProducts = [];
  }
}
