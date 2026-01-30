class CheckoutSummary {
  final String addressId;
  final String addressText;
  final List<CheckoutItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double grandTotal;

  CheckoutSummary({
    required this.addressId,
    required this.addressText,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.grandTotal,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    // Handle API nesting variations
    final data = json.containsKey('address') ? json : json['data'] ?? json;
    final address = data['address'] ?? {};

    return CheckoutSummary(
      addressId: address['id'] ?? '',
      addressText: address['addressText'] ?? 'Unknown Address',
      items: (data['items'] as List?)
              ?.map((e) => CheckoutItem.fromJson(e))
              .toList() ?? [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (data['grandTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CheckoutItem {
  final String productName;
  final String productImage; // ✅ NEW
  final int quantity;
  final double lineTotal;

  CheckoutItem({
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.lineTotal,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      productName: json['productName'] ?? 'Unknown Item',
      // Ensure your API returns 'productImage' or 'image'
      productImage: json['productImage'] ?? json['image'] ?? '', 
      quantity: json['quantity'] ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}