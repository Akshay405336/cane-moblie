import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this dependency
import '../models/cart.model.dart';
import '../models/cart_item.model.dart';
import '../services/cart_api.dart';

class CartController extends ValueNotifier<Cart> {
  CartController._() : super(Cart.empty()) {
    // Automatically try to restore the last outlet ID on startup
    _restoreOutletId();
  }

  static final instance = CartController._();

  bool _loading = false;
  String? _outletId;

  bool get isLoading => _loading;
  String? get currentOutletId => _outletId; 

  /* ================================================= */
  /* PERSISTENCE HELPERS                              */
  /* ================================================= */

  Future<void> _restoreOutletId() async {
    final prefs = await SharedPreferences.getInstance();
    _outletId = prefs.getString('last_outlet_id');
    if (_outletId != null) {
      load(); // Auto-load if we found a saved ID
    }
  }

  Future<void> _saveOutletId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_outlet_id', id);
  }

  /* ================================================= */
  /* OUTLET CONTEXT                                   */
  /* ================================================= */

  void setOutlet(String outletId) {
    if (_outletId != outletId) {
      _outletId = outletId;
      _saveOutletId(outletId);
    }
  }

  void _ensureOutlet() {
    if (_outletId == null) {
      throw Exception('OutletId not set in CartController');
    }
  }

  /* ================================================= */
  /* INTERNAL HELPERS                                 */
  /* ================================================= */

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setCart(Cart? newCart) {
    if (newCart == null) {
      value = Cart.empty();
      return;
    }
    // Maintain local sorting logic
    if (value.items.isNotEmpty && newCart.items.isNotEmpty) {
      final Map<String, int> currentOrder = {
        for (int i = 0; i < value.items.length; i++) value.items[i].productId: i
      };
      newCart.items.sort((a, b) {
        final indexA = currentOrder[a.productId] ?? 999;
        final indexB = currentOrder[b.productId] ?? 999;
        return indexA.compareTo(indexB);
      });
    }
    value = newCart;
  }

  /* ================================================= */
  /* LOAD CART - Updated with better error handling   */
  /* ================================================= */

  Future<void> load() async {
    if (_outletId == null) {
      debugPrint("🛒 Cart load skipped: No outlet ID found.");
      return;
    }

    try {
      _setLoading(true);
      final fetchedCart = await CartApi.getCart(outletId: _outletId!);
      _setCart(fetchedCart);
    } catch (e) {
      debugPrint("🛒 Cart load error: $e");
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
      final shouldForceReplace = _outletId == null || _outletId != outletId;
      
      _outletId = outletId;
      _saveOutletId(outletId); // Save for next app restart

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

  // --- KEEPING YOUR OTHER METHODS EXACTLY AS THEY WERE ---

  Future<void> updateQty(String productId, int qty) async {
    _ensureOutlet();
    try {
      _setLoading(true);
      if (qty <= 0) {
        _setCart(await CartApi.remove(outletId: _outletId!, productId: productId));
      } else {
        _setCart(await CartApi.updateQty(outletId: _outletId!, productId: productId, quantity: qty));
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> remove(String productId) async {
    _ensureOutlet();
    try {
      _setLoading(true);
      _setCart(await CartApi.remove(outletId: _outletId!, productId: productId));
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    value = Cart.empty();
    _outletId = null;
    notifyListeners();
  }

  Future<void> mergeLocalItems({required List<CartItem> localItems, required String outletId}) async {
    if (localItems.isEmpty) return;
    try {
      _setLoading(true);
      _outletId = outletId;
      _saveOutletId(outletId);
      await Future.wait(localItems.map((item) => CartApi.addItem(
            outletId: outletId,
            productId: item.productId,
            quantity: item.quantity,
            forceReplace: true,
          )));
      _setCart(await CartApi.getCart(outletId: outletId));
    } finally {
      _setLoading(false);
    }
  }

  List<CartItem> get items => List.unmodifiable(value.items);
  int get itemCount => value.itemCount;
  double get grandTotal => value.grandTotal;
  bool get isEmpty => value.items.isEmpty;
  bool get hasCart => value.items.isNotEmpty;

  bool isSameOutlet(String outletId) => _outletId == outletId;
}