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
  /* EMPTY (for when API returns data: null)           */
  /* ================================================= */

  factory Cart.empty() => const Cart(
        id: '',
        outletId: '',
        currency: 'INR',
        items: [],
        itemCount: 0,
        subtotal: 0,
        discount: 0,
        afterDiscountTotal: 0,
        deliveryFee: 0,
        grandTotal: 0,
      );

  /* ================================================= */
  /* JSON                                              */
  /* ================================================= */

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id']?.toString() ?? '',
      outletId: json['outletId']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'INR',

      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e))
          .toList(),

      // safer int parsing (handles "2" or 2)
      itemCount: int.tryParse(json['itemCount']?.toString() ?? '0') ?? 0,

      subtotal: _d(json['subtotal']),
      discount: _d(json['discount']),
      afterDiscountTotal: _d(json['afterDiscountTotal']),
      deliveryFee: _d(json['deliveryFee']),
      grandTotal: _d(json['grandTotal']),
    );
  }

  /* ================================================= */
  /* SAFE DOUBLE PARSER                                */
  /* ================================================= */

  static double _d(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;
}
