import 'package:flutter/material.dart';
import '../models/cart_item.model.dart';
import 'package:uuid/uuid.dart';

/// =================================================
/// LOCAL CART (Guest only)
/// =================================================
///
/// • Used before login only
/// • Temporary memory cart
/// • No backend
/// • No money logic from server
/// • Merged into server cart after login
///
class LocalCartController extends ValueNotifier<List<CartItem>> {
  LocalCartController._() : super(const []);

  static final instance = LocalCartController._();

  /* ================================================= */
  /* INTERNAL HELPER                                   */
  /* ================================================= */

  List<CartItem> _clone() => [...value];

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
        id: const Uuid().v4(), // ⭐ FIX HERE
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

  value = items;
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

    value = items;
  }

  /* ================================================= */
  /* REMOVE                                            */
  /* ================================================= */

  void remove(String productId) {
    value = value
        .where((e) => e.productId != productId)
        .toList();
  }

  /* ================================================= */
  /* CLEAR                                             */
  /* ================================================= */

  void clear() {
    value = const [];
  }

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  List<CartItem> get items => List.unmodifiable(value);

  int get totalItems =>
      value.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      value.fold(0, (sum, e) => sum + e.total);

  bool get isEmpty => value.isEmpty;
}
