import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';
import '../models/cart_item.model.dart';

import '../../auth/state/auth_controller.dart';
import '../../location/state/location_controller.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../../utils/auth_required_action.dart';
import '../../../core/network/url_helper.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Modern grey background
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: AnimatedBuilder(
        animation: AuthController.instance,
        builder: (_, __) {
          final isLoggedIn = AuthController.instance.isLoggedIn;
          // FIX: Cast to Listenable to support ChangeNotifier
          final Listenable listenable = isLoggedIn 
              ? CartController.instance 
              : LocalCartController.instance;

          return AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final server = CartController.instance;
              final local = LocalCartController.instance;

              final items = isLoggedIn ? server.items : local.items;
              final isLoading = isLoggedIn && server.isLoading;
              
              // Calculate total
              final grandTotal = isLoggedIn
                  ? server.grandTotal
                  : local.items.fold<double>(0, (sum, e) => sum + e.total);

              if (isLoading && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (items.isEmpty) {
                return const _EmptyCartView();
              }

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = items[index];
                                return _CartCard(
                                  key: ValueKey(item.productId),
                                  item: item,
                                  isLoggedIn: isLoggedIn,
                                );
                              },
                              childCount: items.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CheckoutBottomBar(
                    itemCount: items.length,
                    grandTotal: grandTotal,
                    isLoggedIn: isLoggedIn,
                    loading: isLoading,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENHANCED UI WIDGETS
// ---------------------------------------------------------------------------

class _CartCard extends StatelessWidget {
  final CartItem item;
  final bool isLoggedIn;

  const _CartCard({
    required Key key,
    required this.item,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key('del_${item.productId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color(0xFFFFE5E5),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) {
            if (isLoggedIn) {
              CartController.instance.updateQty(item.productId, 0);
            } else {
              LocalCartController.instance.updateQty(item.productId, 0);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                _CartImage(path: item.image),
                const SizedBox(width: 16),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${item.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          _ModernQtyControl(
                            qty: item.quantity,
                            onChanged: (val) {
                              if (isLoggedIn) {
                                CartController.instance.updateQty(item.productId, val);
                              } else {
                                LocalCartController.instance.updateQty(item.productId, val);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item?"),
        content: const Text("Are you sure you want to remove this item?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _ModernQtyControl extends StatelessWidget {
  final int qty;
  final Function(int) onChanged;
  
  const _ModernQtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TapIcon(Icons.remove, () => onChanged(qty - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          _TapIcon(Icons.add, () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _TapIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TapIcon(this.icon, this.onTap);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: Colors.grey[800]),
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int itemCount;
  final double grandTotal;
  final bool isLoggedIn;
  final bool loading;

  const _CheckoutBottomBar({
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
                onPressed: loading ? null : () => _processCheckout(context),
                child: loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

  Future<void> _processCheckout(BuildContext context) async {
    await AuthRequiredAction.run(
      context,
      action: () async {
        try {
          final locationCtrl = Provider.of<LocationController>(context, listen: false);
          final currentLoc = locationCtrl.current;
          final addressId = currentLoc?.savedAddressId;

          if (addressId != null && addressId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CheckoutScreen(initialAddressId: addressId)),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a delivery address first.")),
            );
          }
        } catch (e) {
          debugPrint("Location Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not verify location.")),
          );
        }
      },
    );
  }
}

class _CartImage extends StatelessWidget {
  final String path;
  const _CartImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return Container(
        width: 70, height: 70,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    final url = UrlHelper.full(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url, width: 70, height: 70, fit: BoxFit.cover,
        errorBuilder: (_,__,___) => Container(
          width: 70, height: 70, color: Colors.grey[200], 
          child: const Icon(Icons.broken_image, color: Colors.grey)
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Add items to start ordering", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}