import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes.dart';
import '../../../utils/auth_required_action.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../location/models/location.model.dart';
import '../../location/state/location_controller.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';
import '../../saved_address/state/saved_address_controller.dart';
import '../../store/services/outlet_socket_service.dart';
import '../../store/services/outlet_verification_service.dart';
import '../state/cart_controller.dart';
import 'address_selection_sheet.dart';

class CheckoutBottomBar extends StatelessWidget {
  final int itemCount;
  final double grandTotal;
  final bool isLoggedIn;
  final bool loading;

  const CheckoutBottomBar({
    super.key,
    required this.itemCount,
    required this.grandTotal,
    required this.isLoggedIn,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total ($itemCount items)', style: TextStyle(color: Colors.grey[600])),
                Text(
                  '₹${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: loading ? null : () => _handleCheckoutAction(context),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isLoggedIn ? 'Proceed to Checkout' : 'Login to Checkout',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckoutAction(BuildContext context) async {
    return AuthRequiredAction.run(
      context,
      action: () async {
        final addressCtrl = Provider.of<SavedAddressController>(context, listen: false);
        await addressCtrl.load(forceRefresh: true);

        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFFF8F9FA),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (ctx) => AddressSelectionSheet(
              addressCtrl: addressCtrl,
              onAddressSelected: (selectedAddress) {
                _verifyProximityAndProceed(context, selectedAddress);
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _verifyProximityAndProceed(BuildContext context, LocationData selectedAddress) async {
    try {
      final outletSocket = OutletSocketService.instance;
      final currentOutletId = CartController.instance.currentOutletId;

      if (outletSocket.cachedOutlets.isEmpty) throw "Outlet data not available.";

      final currentOutlet = outletSocket.cachedOutlets.firstWhere(
        (o) => o.id == currentOutletId,
        orElse: () => outletSocket.cachedOutlets.first,
      );

      bool isNear = OutletVerificationService.isWithinRange(
        address: selectedAddress,
        currentOutletLat: currentOutlet.latitude.toString(),
        currentOutletLng: currentOutlet.longitude.toString(),
      );

      if (isNear) {
        final locCtrl = Provider.of<LocationController>(context, listen: false);
        await locCtrl.setSaved(selectedAddress);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(initialAddressId: selectedAddress.savedAddressId!),
            ),
          );
        }
      } else {
        _showFarOutletDialog(context, selectedAddress);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showFarOutletDialog(BuildContext context, LocationData address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Outlet is Far Away"),
        content: const Text("This outlet is too far from your selected address. We need to clear your cart so you can switch to a closer outlet."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              CartController.instance.clear();
              final locCtrl = Provider.of<LocationController>(context, listen: false);
              await locCtrl.setSaved(address);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
              }
            },
            child: const Text("Clear Cart & Go Home"),
          ),
        ],
      ),
    );
  }
}