import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/http_client.dart';
import '../../../core/network/url_helper.dart'; // ✅ Using UrlHelper for images
import '../../../routes.dart';
import '../../orders/models/order.model.dart'; // ✅ Ensure this path is correct for your project

class ReorderPage extends StatefulWidget {
  const ReorderPage({Key? key}) : super(key: key);

  @override
  State<ReorderPage> createState() => _ReorderPageState();
}

class _ReorderPageState extends State<ReorderPage> {
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
      backgroundColor: const Color(0xFFF5F6F8), // Clean grey background
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button if it's a main tab
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
                        return _OrderTile(order: _orders[index]);
                      },
                    ),
            ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.history,
              size: 44,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Once you place your first order,\nyou’ll see it here for quick reordering 🍹',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF558B2F),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ORDER TILE WIDGET ---
class _OrderTile extends StatelessWidget {
  final Order order;
  
  const _OrderTile({required this.order});

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

    // 2. Image URL Construction (Using UrlHelper)
    final imageUrl = UrlHelper.full(order.firstProductImage);

    // 3. Status Color
    final statusColor = _getStatusColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to Order Details
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                
                // Middle Row: Image & Info
                Row(
                  children: [
                    // Image Box
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey[100],
                        child: order.firstProductImage.isEmpty
                            ? const Icon(Icons.local_drink, color: Colors.grey)
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
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
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.itemCount > 1 
                                ? "+ ${order.itemCount - 1} more items" 
                                : "1 Item",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      "₹${order.grandTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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