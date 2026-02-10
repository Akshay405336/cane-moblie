import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../location/state/location_controller.dart';
import '../../saved_address/state/saved_address_controller.dart';

import '../state/checkout_controller.dart';
import '../models/checkout_summary.model.dart';
import 'order_success_screen.dart';

// Import your split widgets
import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_item_list.dart';
import '../widgets/checkout_bill_summary.dart';
import '../widgets/address_selector_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final String? initialAddressId;
  const CheckoutScreen({super.key, this.initialAddressId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 Initialize Razorpay Listeners
    CheckoutController.instance.initRazorpay();
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  @override
  void dispose() {
    // 🔥 Clean up Razorpay Listeners
    CheckoutController.instance.disposeRazorpay();
    super.dispose();
  }

  void _initLoad() {
    final locationCtrl = Provider.of<LocationController>(context, listen: false);
    final addressId = widget.initialAddressId ?? locationCtrl.current?.savedAddressId;

    if (addressId != null && addressId.isNotEmpty) {
      CheckoutController.instance.loadSummary(addressId);
    } else {
      Provider.of<SavedAddressController>(context, listen: false).load();
    }
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const AddressSelectorSheet(),
      ),
    );
  }

  Future<void> _handlePay() async {
    try {
      // This waits for the entire Razorpay flow to complete
      final order = await CheckoutController.instance.placeOrder();
      
      if (order != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      // Catch errors from Controller (User cancelled or API fail)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Failed: ${e.toString().replaceAll('Exception:', '')}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text(
          "Review & Pay",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: ValueListenableBuilder<CheckoutSummary?>(
        valueListenable: CheckoutController.instance,
        builder: (context, summary, _) {
          
          // 1. Loading State
          if (CheckoutController.instance.isLoading && summary == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5, color: HomeColors.primaryGreen),
                  SizedBox(height: 16),
                  Text("Preparing checkout...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 2. Empty/No Address State
          if (summary == null) {
            return _buildNoAddressState();
          }

          // 3. MAIN CONTENT
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Step 1: Address
                CheckoutAddressCard(
                  addressText: summary.addressText,
                  onTap: _showAddressPicker,
                ),
                const SizedBox(height: 20),

                // Step 2: Items
                CheckoutItemList(items: summary.items),
                const SizedBox(height: 20),

                // Step 3: Bill
                CheckoutBillSummary(
                  subtotal: summary.subtotal,
                  deliveryFee: summary.deliveryFee,
                  discount: summary.discount,
                  grandTotal: summary.grandTotal,
                ),

                // Trust Badge
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      "Payments are 100% Secure & Encrypted",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 120), 
              ],
            ),
          );
        },
      ),

      // 4. STICKY FOOTER
      bottomNavigationBar: ValueListenableBuilder<CheckoutSummary?>(
        valueListenable: CheckoutController.instance,
        builder: (context, summary, _) {
          if (summary == null) return const SizedBox.shrink();
          return _buildBottomBar(summary);
        },
      ),
    );
  }

  Widget _buildNoAddressState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_disabled_rounded, size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              "Missing Delivery Location",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please select a delivery address to calculate shipping and taxes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showAddressPicker,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text("Select Address"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CheckoutSummary summary) {
    final isLoading = CheckoutController.instance.isLoading;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Payable", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  Text(
                    "₹${summary.grandTotal.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handlePay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: isLoading ? 0 : 4,
                    shadowColor: HomeColors.primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "PLACE ORDER",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}