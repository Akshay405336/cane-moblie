import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/http_client.dart';
import '../../../routes.dart';
import '../models/order.model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final res = await AppHttpClient.dio.get('/my-orders');
      
      if (res.data != null && (res.data['data'] is List)) {
        final List data = res.data['data'];
        if (mounted) {
          setState(() {
            _orders = data.map((e) => Order.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Orders Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ProOrderTile(order: _orders[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _ProOrderTile extends StatelessWidget {
  final Order order;
  
  // ✅ UPDATED BASE URL FROM YOUR LOGS
  static const String _baseUrl = "https://psp-reprint-websites-entered.trycloudflare.com/";

  const _ProOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    // 1. Date Formatting
    String formattedDate = order.orderDate;
    try {
      if (order.orderDate.isNotEmpty) {
        final date = DateTime.parse(order.orderDate);
        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      }
    } catch (_) {}

    // 2. Image URL Construction
    String imageUrl = order.firstProductImage;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // Remove leading slash if strictly necessary, usually valid URLs ignore double slash
      if (imageUrl.startsWith('/')) imageUrl = imageUrl.substring(1);
      imageUrl = "$_baseUrl$imageUrl";
    }

    // 3. Status Color
    final statusColor = _getStatusColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Top Row: Date & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                
                // Middle Row: Image & Info
                Row(
                  children: [
                    // Image Box
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.fastfood, color: Colors.grey)
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.firstProductName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.itemCount > 1 
                                ? "+ ${order.itemCount - 1} more items" 
                                : "1 Item",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${order.grandTotal.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'DELIVERED':
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
      case 'PAYMENT_PENDING':
        return Colors.orange;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}