import 'cart_item.model.dart';

class Cart {
  final String id;
  final String outletId;
  final String currency;

  final List<CartItem> items;
  final int itemCount;

  final double subtotal;
  final double discount;
  final double afterDiscountTotal;
  final double deliveryFee;
  final double grandTotal;

  const Cart({
    required this.id,
    required this.outletId,
    required this.currency,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.afterDiscountTotal,
    required this.deliveryFee,
    required this.grandTotal,
  });

  /* ================================================= */
  /* JSON                                              */
  /* ================================================= */

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      outletId: json['outletId'] ?? '',
      currency: json['currency'] ?? 'INR',

      items: (json['items'] as List? ?? [])
          .map((e) => CartItem.fromJson(e))
          .toList(),

      itemCount: json['itemCount'] ?? 0,

      subtotal: _d(json['subtotal']),
      discount: _d(json['discount']),
      afterDiscountTotal: _d(json['afterDiscountTotal']),
      deliveryFee: _d(json['deliveryFee']),
      grandTotal: _d(json['grandTotal']),
    );
  }

  /* ================================================= */
  /* SAFE DOUBLE PARSER (handles "120" or 120)         */
  /* ================================================= */

  static double _d(dynamic v) =>
      double.tryParse(v.toString()) ?? 0;
}
