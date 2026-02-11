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
  String? get currentOutletId => _outletId; 

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

  /// ⭐ Logic Fixed: Sorts the incoming list to match the current local order
  void _setCart(Cart? newCart) {
    if (newCart == null) {
      value = Cart.empty();
      return;
    }

    // If we already have items locally, we sort the new list to match the old order
    if (value.items.isNotEmpty && newCart.items.isNotEmpty) {
      // Create a map of the current positions for quick lookup
      final Map<String, int> currentOrder = {
        for (int i = 0; i < value.items.length; i++) value.items[i].productId: i
      };

      // Sort the incoming items list based on the current existing order
      // Items not in the current list will be placed at the end
      newCart.items.sort((a, b) {
        final indexA = currentOrder[a.productId] ?? 999;
        final indexB = currentOrder[b.productId] ?? 999;
        return indexA.compareTo(indexB);
      });
    }

    value = newCart;
  }

  /* ================================================= */
  /* LOAD CART                                         */
  /* ================================================= */

  Future<void> load() async {
    if (_outletId == null) return;

    try {
      _setLoading(true);
      _setCart(await CartApi.getCart(outletId: _outletId!));
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
    bool forceReplace = false,
  }) async {
    try {
      _setLoading(true);

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
  /* UPDATE QTY                                        */
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
  /* REMOVE ITEM                                       */
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
  /* CLEAR                                             */
  /* ================================================= */

  void clear() {
    value = Cart.empty();
    _outletId = null;
    notifyListeners();
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
  /* HELPERS                                           */
  /* ================================================= */

  List<CartItem> get items => List.unmodifiable(value.items);
  int get itemCount => value.itemCount;
  double get grandTotal => value.grandTotal;
  bool get isEmpty => value.items.isEmpty;
  bool get hasCart => value.items.isNotEmpty;

  /* ================================================= */
  /* OUTLET UI HELPER                                 */
  /* ================================================= */

  bool isSameOutlet(String outletId) {
    return _outletId == outletId;
  }
}