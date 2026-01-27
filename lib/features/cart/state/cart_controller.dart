import 'package:flutter/material.dart';

import '../models/cart.model.dart';
import '../models/cart_item.model.dart';
import '../services/cart_api.dart';

/// =================================================
/// SERVER CART (logged-in users only)
/// =================================================
///
/// ⭐ Single source of truth
/// ⭐ All totals come from backend
/// ⭐ No price math here
///
class CartController extends ValueNotifier<Cart?> {
  CartController._() : super(null);

  static final instance = CartController._();

  bool _loading = false;

  bool get isLoading => _loading;

  /* ================================================= */
  /* INTERNAL LOADING HELPER                           */
  /* ================================================= */

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /* ================================================= */
  /* LOAD                                              */
  /* ================================================= */

  Future<void> load() async {
    try {
      _setLoading(true);

      value = await CartApi.getCart();
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* ADD ITEM                                          */
  /* ================================================= */

  Future<void> addItem({
    required String outletId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      _setLoading(true);

      value = await CartApi.addItem(
        outletId: outletId,
        productId: productId,
        quantity: quantity,
      );
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* UPDATE QTY                                        */
  /* ================================================= */

  Future<void> updateQty(String productId, int qty) async {
    try {
      _setLoading(true);

      if (qty <= 0) {
        value = await CartApi.remove(productId);
      } else {
        value = await CartApi.updateQty(
          productId: productId,
          quantity: qty,
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* REMOVE                                            */
  /* ================================================= */

  Future<void> remove(String productId) async {
    try {
      _setLoading(true);

      value = await CartApi.remove(productId);
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* CLEAR (logout only — local reset)                  */
  /* ================================================= */

  void clear() {
    value = null;
    notifyListeners();
  }

  /* ================================================= */
  /* 🔥 MERGE LOCAL → SERVER (LOGIN MAGIC)              */
  /* ================================================= */
  ///
  /// ⭐ Fast parallel merge
  /// ⭐ 5–10x faster than sequential
  ///
  Future<void> mergeLocalItems({
    required List<CartItem> localItems,
    required String outletId,
  }) async {
    if (localItems.isEmpty) return;

    try {
      _setLoading(true);

      await Future.wait(
        localItems.map(
          (item) => CartApi.addItem(
            outletId: outletId,
            productId: item.productId,
            quantity: item.quantity,
          ),
        ),
      );

      value = await CartApi.getCart();
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  List<CartItem> get items =>
      List.unmodifiable(value?.items ?? const []);

  int get itemCount => value?.itemCount ?? 0;

  double get grandTotal => value?.grandTotal ?? 0;

  bool get isEmpty => items.isEmpty;

  bool get hasCart => value != null;
}
