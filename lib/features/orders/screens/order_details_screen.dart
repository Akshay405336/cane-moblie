import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/http_client.dart';
import '../../../core/network/url_helper.dart'; // ✅ Added UrlHelper
// import '../../../env.dart'; // ❌ Removed Env import (Not needed with UrlHelper)

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? order;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _load(args);
    }
  }

  Future<void> _load(String orderId) async {
    setState(() => loading = true);
    try {
      final res = await AppHttpClient.dio.get('/orders/$orderId');
      if (mounted) {
        setState(() {
          order = res.data['data'];
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Clean grey background
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : order == null
              ? const Center(child: Text("Failed to load order"))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final items = (order!['items'] as List?) ?? [];
    final address = order!['address'] ?? {};
    final status = order!['status'] ?? 'PENDING';
    final dateStr = order!['createdAt'] ?? '';
    final orderId = order!['id'] ?? '...';
    
    // ⭐ NEW: Extract orderNumber from backend data
    final orderNumber = order!['orderNumber']?.toString() ?? '';

    // 1. Format Date
    String formattedDate = dateStr;
    try {
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      }
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER CARD (orderNumber, Date, Status) ===
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        // ⭐ Updated to show orderNumber. Fallback to ID substring if empty.
                        orderNumber.isNotEmpty 
                            ? "Order #$orderNumber" 
                            : "Order #${orderId.toString().substring(0, 8).toUpperCase()}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    _StatusChip(status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // === ITEMS LIST ===
          const _SectionHeader("Items"),
          Container(
            decoration: _boxDecoration(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ItemTile(item: item);
              },
            ),
          ),

          const SizedBox(height: 24),

          // === ADDRESS CARD ===
          const _SectionHeader("Delivery Location"),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['label']?.toString().toUpperCase() ?? 'ADDRESS',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address['addressText'] ?? '',
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // === BILL SUMMARY ===
          const _SectionHeader("Payment Summary"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _SummaryRow("Subtotal", order!['subtotal']),
                _SummaryRow("Discount", order!['discount'], isDiscount: true),
                _SummaryRow("Delivery Fee", order!['deliveryFee']),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                _SummaryRow("Grand Total", order!['grandTotal'], isTotal: true),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// =========================================================
// HELPER WIDGETS
// =========================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final imgUrl = UrlHelper.full(item['productImage']?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[100],
              child: item['productImage'] == null || item['productImage'] == ''
                  ? const Icon(Icons.fastfood, size: 20, color: Colors.grey)
                  : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "x${item['quantity']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            "₹${item['unitPrice']}",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow(this.label, this.value, {this.isTotal = false, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    double val = 0.0;
    if (value != null) {
      val = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            "${isDiscount ? '-' : ''}₹${val.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount ? Colors.green : (isTotal ? Colors.black : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'DELIVERED':
      case 'SUCCESS':
        color = Colors.green;
        break;
      case 'PENDING':
      case 'PAYMENT_PENDING':
        color = Colors.orange;
        break;
      case 'CANCELLED':
      case 'FAILED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}