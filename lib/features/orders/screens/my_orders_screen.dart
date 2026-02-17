import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/http_client.dart';
import '../../../core/network/url_helper.dart'; 
import '../../../routes.dart';
import '../models/order.model.dart';

// --- PREMIUM DESIGN CONSTANTS ---
const kBrandGreen = Color(0xFF2E7D32);
const kBackground = Color(0xFFF8FAFB);
const kCardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
];

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
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      ),
      body: _isLoading
          ? _buildSkeletonLoader() 
          : RefreshIndicator(
              color: kBrandGreen,
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _ProOrderTile(order: _orders[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Opacity(
          opacity: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(width: 80, height: 12, color: Colors.grey[200]),
                Container(width: 60, height: 12, color: Colors.grey[200]),
              ]),
              const Divider(height: 30),
              Row(children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 150, height: 12, color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 10, color: Colors.grey[200]),
                ])
              ])
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kCardShadow),
            child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No orders yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 8),
          const Text('Your shopping journey starts here!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProOrderTile extends StatelessWidget {
  final Order order;
  
  const _ProOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Recent";
    try {
      if (order.orderDate.isNotEmpty) {
        final date = DateTime.parse(order.orderDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (_) {}

    final imageUrl = UrlHelper.full(order.firstProductImage);
    final statusColor = _getStatusColor(order.status);
    
    // ⭐ Logic for Item Count Display
    final bool hasMoreItems = order.itemCount > 1;
    final String itemsSummary = hasMoreItems 
        ? "and ${order.itemCount - 1} other items" 
        : "1 Item only";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Order ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        order.orderNumber.isNotEmpty ? "#${order.orderNumber}" : "ORDER INFO",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black54),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Content: Image & Product Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'order-${order.id}',
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: order.firstProductImage.isEmpty
                              ? const Icon(Icons.receipt_long, color: Colors.grey)
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.firstProductName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 4),
                          // ⭐ Enhanced Item Summary
                          Text(
                            itemsSummary,
                            style: TextStyle(
                              fontSize: 12, 
                              color: hasMoreItems ? kBrandGreen : Colors.grey[500], 
                              fontWeight: hasMoreItems ? FontWeight.w700 : FontWeight.w500
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Ordered: $formattedDate",
                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                
                // Footer: Total & View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Grand Total", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                        Text(
                          "₹${order.grandTotal.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: kBrandGreen,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                           BoxShadow(color: kBrandGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                        ]
                      ),
                      child: const Row(
                        children: [
                          Text("VIEW DETAILS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                        ],
                      ),
                    ),
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
        return const Color(0xFF2E7D32); 
      case 'PENDING':
      case 'PAYMENT_PENDING':
      case 'SHIPPED':
        return const Color(0xFFF57C00); 
      case 'CANCELLED':
      case 'FAILED':
        return const Color(0xFFD32F2F); 
      default:
        return Colors.grey;
    }
  }
}