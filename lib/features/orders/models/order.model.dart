class Order {
  final String id;
  final String status;
  final double grandTotal;
  final String orderDate;
  final int itemCount;
  final String firstProductImage;
  final String firstProductName;

  Order({
    required this.id,
    required this.status,
    required this.grandTotal,
    required this.orderDate,
    required this.itemCount,
    required this.firstProductImage,
    required this.firstProductName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // 1. Handle generic 'data' wrapper if it exists
    final data = json.containsKey('data') ? json['data'] : json;

    // 2. Helpers to prevent NULL crashes
    String safeStr(dynamic val) => val?.toString() ?? '';
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      return (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0;
    }
    int safeInt(dynamic val) {
      if (val == null) return 0;
      return (val is num) ? val.toInt() : int.tryParse(val.toString()) ?? 0;
    }

    // 3. Robust Item Parsing (The Crash Fix)
    String img = '';
    String name = 'Unknown Item';

    try {
      if (data['items'] != null && data['items'] is List) {
        final List list = data['items'];
        if (list.isNotEmpty) {
          final first = list[0];
          img = safeStr(first['productImage']);
          name = safeStr(first['productName']);
        }
      }
    } catch (e) {
      // If parsing fails, use defaults. Do not crash.
      img = '';
      name = 'Error Item';
    }

    return Order(
      id: safeStr(data['id']),
      status: safeStr(data['status']).isEmpty ? 'PENDING' : safeStr(data['status']),
      grandTotal: safeDouble(data['grandTotal']),
      orderDate: safeStr(data['createdAt']),
      itemCount: safeInt(data['itemCount']),
      firstProductImage: img,
      firstProductName: name.isEmpty ? 'Order #${safeStr(data['id']).substring(0, 4)}' : name,
    );
  }
}