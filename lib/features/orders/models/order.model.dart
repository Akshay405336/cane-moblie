import 'package:flutter/foundation.dart'; // ⭐ Added this for debugPrint

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final double grandTotal;
  final String orderDate;
  final int itemCount;
  final String firstProductImage;
  final String firstProductName;

  Order({
    required this.id,
    required this.orderNumber,
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

    // 3. Robust Item Parsing
    String img = '';
    String name = ''; // Start empty to check fallbacks

    try {
      // Priority A: Extract from items list (Full Order Details API)
      if (data['items'] != null && data['items'] is List) {
        final List list = data['items'];
        if (list.isNotEmpty) {
          final first = list[0];
          img = safeStr(first['productImage']);
          name = safeStr(first['productName']);
        }
      } 
      
      // Priority B: Extract from direct summary fields (Optimized List API)
      if (name.isEmpty) {
        name = safeStr(data['firstProductName']);
      }
      if (img.isEmpty) {
        img = safeStr(data['firstProductImage']);
      }
    } catch (e) {
      debugPrint("Parsing error in Order Model: $e");
    }

    final String displayOrderNum = safeStr(data['orderNumber']);
    
    // ⭐ Logic for name fallback: use orderNumber instead of substring of ID
    // This ensures your list view shows "Order #CNT-..." instead of "Unknown Item"
    final String finalName = (name.isEmpty || name == 'Unknown Item')
        ? (displayOrderNum.isNotEmpty 
            ? 'Order #$displayOrderNum' 
            : 'Order #${safeStr(data['id']).substring(0, 8).toUpperCase()}') 
        : name;

    return Order(
      id: safeStr(data['id']),
      orderNumber: displayOrderNum,
      status: safeStr(data['status']).isEmpty ? 'PENDING' : safeStr(data['status']),
      grandTotal: safeDouble(data['grandTotal']),
      orderDate: safeStr(data['createdAt']),
      itemCount: safeInt(data['itemCount']),
      firstProductImage: img,
      firstProductName: finalName,
    );
  }
}