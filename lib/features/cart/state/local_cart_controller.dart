import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.model.dart';

/// =================================================
/// LOCAL CART (Guest only)
/// =================================================
///
/// • Used before login only
/// • Temporary memory cart
/// • No backend
/// • Merged into server cart after login
///
class LocalCartController extends ValueNotifier<List<CartItem>> {
  LocalCartController._() : super(const []);

  static final instance = LocalCartController._();

  static const _uuid = Uuid();

  /* ================================================= */
  /* INTERNAL HELPER                                   */
  /* ================================================= */

  List<CartItem> _clone() => [...value];

  void _set(List<CartItem> items) {
    value = List.unmodifiable(items);
  }

  /* ================================================= */
  /* ADD ITEM                                          */
  /* ================================================= */

  void addItem({
    required String productId,
    required String name,
    required String image,
    required double unitPrice,
    double? discountPrice,
    int quantity = 1,
  }) {
    final items = _clone();

    final index =
        items.indexWhere((e) => e.productId == productId);

    if (index >= 0) {
      final current = items[index];

      items[index] = current.copyWith(
        quantity: current.quantity + quantity,
      );
    } else {
      items.add(
        CartItem(
          id: _uuid.v4(),
          productId: productId,
          name: name,
          image: image,
          quantity: quantity,
          unitPrice: unitPrice,
          discountPrice: discountPrice,
          lineTotal: null,
        ),
      );
    }

    _set(items);
  }

  /* ================================================= */
  /* UPDATE QTY                                        */
  /* ================================================= */

  void updateQty(String productId, int qty) {
    final items = _clone();

    final index =
        items.indexWhere((e) => e.productId == productId);

    if (index == -1) return;

    if (qty <= 0) {
      items.removeAt(index);
    } else {
      items[index] =
          items[index].copyWith(quantity: qty);
    }

    _set(items);
  }

  /* ================================================= */
  /* REMOVE                                            */
  /* ================================================= */

  void remove(String productId) {
    _set(value.where((e) => e.productId != productId).toList());
  }

  /* ================================================= */
  /* CLEAR                                             */
  /* ================================================= */

  void clear() {
    _set(const []);
  }

  /* ================================================= */
  /* HELPERS (match server cart naming)                 */
  /* ================================================= */

  List<CartItem> get items => value;

  /// ⭐ keep naming consistent with server Cart.itemCount
  int get itemCount =>
      value.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      value.fold(0, (sum, e) => sum + e.total);

  bool get isEmpty => value.isEmpty;
}
