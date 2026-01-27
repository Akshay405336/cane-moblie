class CartItem {
  final String id; // ⭐ added (important)
  final String productId;

  final String name;
  final String image;

  final int quantity;

  final double unitPrice;
  final double? discountPrice;
  final double? lineTotal;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.unitPrice,
    this.discountPrice,
    this.lineTotal,
  });

  /* ================================================= */
  /* JSON                                              */
  /* ================================================= */

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['productName'] ?? '',
      image: json['productImage'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: _d(json['unitPrice']),
      discountPrice: json['discountPrice'] != null
          ? _d(json['discountPrice'])
          : null,
      lineTotal: json['lineTotal'] != null
          ? _d(json['lineTotal'])
          : null,
    );
  }

  static double _d(dynamic v) =>
      double.tryParse(v.toString()) ?? 0;

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  double get price => discountPrice ?? unitPrice;

  double get total =>
      lineTotal ?? (price * quantity);

  /* ================================================= */
  /* COPY                                              */
  /* ================================================= */

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    int? quantity,
    double? unitPrice,
    double? discountPrice,
    double? lineTotal,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}
