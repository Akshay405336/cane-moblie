import 'package:flutter/material.dart';

import '../../../core/network/http_client.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  Map<String, dynamic>? order;

  bool loading = true;

  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final orderId =
        ModalRoute.of(context)!.settings.arguments
            as String;

    _load(orderId);
  }

  /* ================================================= */
  /* LOAD ORDER                                        */
  /* ================================================= */

  Future<void> _load(String orderId) async {
    setState(() => loading = true);

    final res =
        await AppHttpClient.dio.get('/orders/$orderId');

    order = res.data['data'];

    setState(() => loading = false);
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildContent(),
    );
  }

  /* ================================================= */
  /* CONTENT                                           */
  /* ================================================= */

  Widget _buildContent() {
    final items = order!['items'] as List? ?? [];
    final address = order!['address'];

    final status = order!['status'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /* ================= STATUS ================= */

        _StatusChip(status),

        const SizedBox(height: 24),

        /* ================= ITEMS ================= */

        const _SectionTitle('Items'),

        ...items.map(
          (e) => ListTile(
            title: Text(e['productName']),
            subtitle:
                Text('₹${e['unitPrice']}'),
            trailing:
                Text('x${e['quantity']}'),
          ),
        ),

        const SizedBox(height: 24),

        /* ================= ADDRESS ================= */

        const _SectionTitle('Delivery Address'),

        Text(address['addressText'] ?? ''),

        const SizedBox(height: 24),

        /* ================= TOTALS ================= */

        const _SectionTitle('Bill Summary'),

        _SummaryTile(
            'Subtotal', order!['subtotal']),
        _SummaryTile(
            'Discount', order!['discount']),
        _SummaryTile(
            'Delivery', order!['deliveryFee']),

        const Divider(),

        _SummaryTile(
          'Grand Total',
          order!['grandTotal'],
          bold: true,
        ),
      ],
    );
  }
}

/* ================================================= */
/* SMALL WIDGETS                                      */
/* ================================================= */

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool bold;

  const _SummaryTile(
    this.label,
    this.value, {
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹$value',
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================================================= */
/* STATUS CHIP                                        */
/* ================================================= */

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'PAID':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'FAILED':
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
              vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
