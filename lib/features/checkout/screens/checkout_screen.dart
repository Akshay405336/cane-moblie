import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/theme/home_colors.dart';
import '../../location/state/location_controller.dart';
import '../../saved_address/state/saved_address_controller.dart';

import '../state/checkout_controller.dart';
import '../models/checkout_summary.model.dart';
import 'order_success_screen.dart';

// Import your split widgets
import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_item_list.dart';
import '../widgets/checkout_bill_summary.dart';

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
    CheckoutController.instance.initRazorpay();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  @override
  void dispose() {
    CheckoutController.instance.disposeRazorpay();
    super.dispose();
  }

  void _initLoad() {
    final locationCtrl =
        Provider.of<LocationController>(context, listen: false);
    final addressId =
        widget.initialAddressId ?? locationCtrl.current?.savedAddressId;

    if (addressId != null && addressId.isNotEmpty) {
      CheckoutController.instance.loadSummary(addressId);
    } else {
      Provider.of<SavedAddressController>(context, listen: false).load();
    }
  }

  /* ===================================================== */
  /* 🔥 UPDATED PAY HANDLER WITH PENDING ORDER POPUP       */
  /* ===================================================== */

  Future<void> _handlePay() async {
    try {
      final order = await CheckoutController.instance.placeOrder();

      // 🔥 If pending order detected → Show popup
      if (CheckoutController.instance.hasPendingOrder && mounted) {
        _showPendingOrderDialog(
            CheckoutController.instance.error ??
                "You already have a pending order.");
        return;
      }

      // 🔥 If payment completed successfully
      if (order != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Payment Failed: ${e.toString().replaceAll('Exception:', '')}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /* ===================================================== */
  /* 🔥 Pending Order Dialog                               */
  /* ===================================================== */

  void _showPendingOrderDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text("Pending Order"),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Review & Pay",
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: ValueListenableBuilder<CheckoutSummary?>(
        valueListenable: CheckoutController.instance,
        builder: (context, summary, _) {
          if (CheckoutController.instance.isLoading &&
              summary == null) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: HomeColors.primaryGreen),
                  SizedBox(height: 16),
                  Text("Preparing checkout...",
                      style:
                          TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (summary == null) {
            return const Center(child: Text("Loading Summary..."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // 🔥 Address is now display-only
                CheckoutAddressCard(
                  addressText: summary.addressText,
                  onTap: () {}, // Pass empty function to disable clicking
                ),
                const SizedBox(height: 20),
                CheckoutItemList(items: summary.items),
                const SizedBox(height: 20),
                CheckoutBillSummary(
                  subtotal: summary.subtotal,
                  deliveryFee: summary.deliveryFee,
                  discount: summary.discount,
                  grandTotal: summary.grandTotal,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 16,
                        color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      "Payments are 100% Secure & Encrypted",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          ValueListenableBuilder<CheckoutSummary?>(
        valueListenable: CheckoutController.instance,
        builder: (context, summary, _) {
          if (summary == null)
            return const SizedBox.shrink();
          return _buildBottomBar(summary);
        },
      ),
    );
  }

  Widget _buildBottomBar(CheckoutSummary summary) {
    final isLoading =
        CheckoutController.instance.isLoading;

    return Container(
      padding: const EdgeInsets.only(
          left: 16, right: 16, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text("Total Payable",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight:
                              FontWeight.w600)),
                  Text(
                    "₹${summary.grandTotal.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : _handlePay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        HomeColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: isLoading ? 0 : 4,
                    shadowColor:
                        HomeColors.primaryGreen
                            .withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              "PLACE ORDER",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                  letterSpacing:
                                      0.5),
                            ),
                            SizedBox(width: 8),
                            Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 20),
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