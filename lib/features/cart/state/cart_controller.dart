import 'package:flutter/material.dart';

import '../models/cart.model.dart';
import '../models/cart_item.model.dart';
import '../services/cart_api.dart';

class CartController extends ValueNotifier<Cart> {
  CartController._() : super(Cart.empty());

  static final instance = CartController._();

  bool _loading = false;
  String? _outletId;

  bool get isLoading => _loading;

  /* ================================================= */
  /* OUTLET CONTEXT                                   */
  /* ================================================= */

  void setOutlet(String outletId) {
    _outletId = outletId;
  }

  void _ensureOutlet() {
    if (_outletId == null) {
      throw Exception('OutletId not set in CartController');
    }
  }

  /* ================================================= */
  /* INTERNAL HELPERS                                  */
  /* ================================================= */

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setCart(Cart? cart) {
    value = cart ?? Cart.empty();
  }

  /* ================================================= */
  /* LOAD CART (SAFE – no crash on app start)          */
  /* ================================================= */

  Future<void> load() async {
    // 🔥 Outlet may not be ready yet during bootstrap
    if (_outletId == null) return;

    try {
      _setLoading(true);
      _setCart(await CartApi.getCart(outletId: _outletId!));
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* ADD ITEM (🔥 FINAL FIX)                           */
  /* ================================================= */

  Future<void> addItem({
    required String outletId,
    required String productId,
    int quantity = 1,
    bool forceReplace = false,
  }) async {
    try {
      _setLoading(true);

      /*
       🔥 CRITICAL FIX
       If this is the FIRST cart action OR outlet changed,
       backend may already have a cart → force replace.
      */
      final shouldForceReplace =
          _outletId == null || _outletId != outletId;

      _outletId = outletId;

      _setCart(await CartApi.addItem(
        outletId: outletId,
        productId: productId,
        quantity: quantity,
        forceReplace: shouldForceReplace || forceReplace,
      ));
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* UPDATE QTY                                       */
  /* ================================================= */

  Future<void> updateQty(String productId, int qty) async {
    _ensureOutlet();

    try {
      _setLoading(true);

      if (qty <= 0) {
        _setCart(await CartApi.remove(
          outletId: _outletId!,
          productId: productId,
        ));
      } else {
        _setCart(await CartApi.updateQty(
          outletId: _outletId!,
          productId: productId,
          quantity: qty,
        ));
      }
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* REMOVE ITEM                                      */
  /* ================================================= */

  Future<void> remove(String productId) async {
    _ensureOutlet();

    try {
      _setLoading(true);
      _setCart(await CartApi.remove(
        outletId: _outletId!,
        productId: productId,
      ));
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* CLEAR (logout only)                              */
  /* ================================================= */

  void clear() {
    value = Cart.empty();
    _outletId = null;
  }

  /* ================================================= */
  /* MERGE LOCAL → SERVER                             */
  /* ================================================= */

  Future<void> mergeLocalItems({
    required List<CartItem> localItems,
    required String outletId,
  }) async {
    if (localItems.isEmpty) return;

    try {
      _setLoading(true);
      _outletId = outletId;

      await Future.wait(
        localItems.map(
          (item) => CartApi.addItem(
            outletId: outletId,
            productId: item.productId,
            quantity: item.quantity,
            forceReplace: true,
          ),
        ),
      );

      _setCart(await CartApi.getCart(outletId: outletId));
    } finally {
      _setLoading(false);
    }
  }

  /* ================================================= */
  /* HELPERS                                          */
  /* ================================================= */

  List<CartItem> get items => List.unmodifiable(value.items);
  int get itemCount => value.itemCount;
  double get grandTotal => value.grandTotal;
  bool get isEmpty => value.items.isEmpty;
  bool get hasCart => value.items.isNotEmpty;
}
