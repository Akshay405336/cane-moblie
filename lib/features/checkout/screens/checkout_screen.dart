import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/state/cart_controller.dart';
import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/models/saved_address.model.dart';

import '../../../core/network/http_client.dart';
import '../../../routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  Map<String, dynamic>? summary;

  SavedAddress? selectedAddress;
  bool loading = false;

  /* ================================================= */
  /* LOAD SUMMARY                                      */
  /* ================================================= */

  Future<void> _loadSummary() async {
    if (selectedAddress == null) return;

    setState(() => loading = true);

    final res = await AppHttpClient.dio.get(
      '/checkout/summary/${selectedAddress!.id}',
    );

    summary = res.data['data'];

    setState(() => loading = false);
  }

  /* ================================================= */
  /* START CHECKOUT                                    */
  /* ================================================= */

  Future<void> _startCheckout() async {
    if (selectedAddress == null) return;

    setState(() => loading = true);

    final res = await AppHttpClient.dio.post(
      '/checkout/start',
      data: {
        "savedAddressId": selectedAddress!.id,
      },
    );

    final orderId = res.data['data']['orderId'];

    setState(() => loading = false);

    Navigator.pushNamed(
      context,
      AppRoutes.orderDetails,
      arguments: orderId,
    );
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final cartItems =
        context.watch<CartController>().items;

    final addressCtrl =
        context.watch<SavedAddressController>();

    final addresses = addressCtrl.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      /* ================= ITEMS ================= */

                      const _SectionTitle('Items'),

                      ...cartItems.map(
                        (e) => ListTile(
                          title: Text(e.name),
                          trailing:
                              Text('x${e.quantity}'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /* ================= ADDRESS ================= */

                      const _SectionTitle(
                          'Delivery Address'),

                      if (addresses.isEmpty)
                        const Text(
                          'No saved address. Please add one.',
                          style:
                              TextStyle(color: Colors.grey),
                        ),

                      ...addresses.map(
                        (a) => RadioListTile<
                            SavedAddress>(
                          value: a,
                          groupValue: selectedAddress,
                          title: Text(a.label),
                          subtitle:
                              Text(a.address), // ✅ FIXED
                          onChanged: (v) async {
                            setState(() {
                              selectedAddress = v;
                            });

                            await _loadSummary();
                          },
                        ),
                      ),

                      TextButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context,
                              AppRoutes.addAddress);

                          context
                              .read<
                                  SavedAddressController>()
                              .refresh();
                        },
                        child:
                            const Text('+ Add Address'),
                      ),

                      const SizedBox(height: 24),

                      /* ================= SUMMARY ================= */

                      if (summary != null) ...[
                        const Divider(),
                        _SummaryTile(
                            'Subtotal',
                            summary!['subtotal']),
                        _SummaryTile(
                            'Discount',
                            summary!['discount']),
                        _SummaryTile(
                            'Delivery',
                            summary!['deliveryFee']),
                        const Divider(),
                        _SummaryTile(
                          'Grand Total',
                          summary!['grandTotal'],
                          bold: true,
                        ),
                      ],
                    ],
                  ),
                ),

                /* ================= PAY BUTTON ================= */

                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: summary == null
                            ? null
                            : _startCheckout,
                        child:
                            const Text('Pay Now'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/* ================================================= */
/* SMALL HELPERS                                      */
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
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
