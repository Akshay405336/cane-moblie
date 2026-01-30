class Order {
  final String id;
  final String status;
  final double grandTotal;
  final String orderDate;

  Order({
    required this.id,
    required this.status,
    required this.grandTotal,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] : json;
    return Order(
      id: data['id'],
      status: data['status'],
      grandTotal: (data['grandTotal'] as num).toDouble(),
      orderDate: data['createdAt'],
    );
  }
}