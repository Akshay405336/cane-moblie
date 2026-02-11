import 'package:caneandtender/features/saved_address/state/saved_address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';

import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';
import '../models/cart_item.model.dart';

import '../../auth/state/auth_controller.dart';
import '../../location/state/location_controller.dart';
import '../../location/models/location.model.dart'; // ⭐ Added for LocationData
import '../../checkout/screens/checkout_screen.dart';
import '../../saved_address/widgets/saved_address_list.dart'; // ⭐ Added for Pop-up
import '../../store/services/outlet_socket_service.dart'; // ⭐ Added for Outlet Data
import '../../store/services/outlet_verification_service.dart'; // ⭐ Added for Range Check
import '../../../utils/auth_required_action.dart';
import '../../../core/network/url_helper.dart';
import '../../../routes.dart'; // ⭐ Added for Navigation

// ⭐ CHANGED: Converted to StatefulWidget to allow initialization logic
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // ⭐ ADDED: Triggers the load() function when the page opens
  @override
  void initState() {
    super.initState();
    // Check if logged in, then fetch data
    if (AuthController.instance.isLoggedIn) {
      // Use addPostFrameCallback to safely call the provider/controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CartController.instance.load();
      });
    }
  }

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

              // Only show loading if we have NO items. 
              // If we are refreshing, keep showing the old items.
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
// UI WIDGETS
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
                _CartImage(path: item.image),
                const SizedBox(width: 16),
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
                                CartController.instance
                                    .updateQty(item.productId, val);
                              } else {
                                LocalCartController.instance
                                    .updateQty(item.productId, val);
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
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Remove", style: TextStyle(color: Colors.red))),
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
            child:
                Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
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

// ---------------------------------------------------------------------------
// CHECKOUT BAR (VERIFICATION LOGIC INSIDE)
// ---------------------------------------------------------------------------

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
          BoxShadow(
              blurRadius: 20, color: Colors.black12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total ($itemCount items)',
                    style: TextStyle(color: Colors.grey[600])),
                Text(
                  '₹${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: loading ? null : () => _showAddressSelection(context),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        isLoggedIn ? 'Proceed to Checkout' : 'Login to Checkout',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⭐ Logic: Pop-up to select address
 Future<void> _showAddressSelection(BuildContext context) async {
  return AuthRequiredAction.run(
    context,
    action: () async {
      final addressCtrl =
          Provider.of<SavedAddressController>(context, listen: false);

      await addressCtrl.load(forceRefresh: true);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFFF8F9FA),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (ctx) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Column(
                children: [

                  /// 🔥 DRAG HANDLE
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on_rounded,
                            color: Colors.black87),
                        SizedBox(width: 8),
                        Text(
                          "Select Delivery Address",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ADDRESS LIST
                  Expanded(
                    child: AnimatedBuilder(
                      animation: addressCtrl,
                      builder: (_, __) {
                        if (addressCtrl.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (addressCtrl.addresses.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off,
                                    size: 60,
                                    color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  "No saved addresses yet",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          itemCount:
                              addressCtrl.addresses.length,
                          itemBuilder: (context, index) {
                            final address =
                                addressCtrl.addresses[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                _verifyProximityAndProceed(
                                  context,
                                  address.toLocationData(),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: 14),
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.05),
                                      blurRadius: 15,
                                      offset:
                                          const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [

                                    /// ICON
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .all(10),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .green.shade50,
                                        shape:
                                            BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    /// TEXT CONTENT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [

                                          /// LABEL + TYPE BADGE
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  address
                                                      .label,
                                                  style:
                                                      const TextStyle(
                                                    fontSize:
                                                        15,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal:
                                                        8,
                                                    vertical:
                                                        4),
                                                decoration:
                                                    BoxDecoration(
                                                  color: Colors
                                                      .grey
                                                      .shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  address
                                                      .type
                                                      .displayName,
                                                  style:
                                                      const TextStyle(
                                                    fontSize:
                                                        11,
                                                    fontWeight:
                                                        FontWeight
                                                            .w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                              height: 6),

                                          Text(
                                            address.address,
                                            style: TextStyle(
                                              color: Colors
                                                  .grey
                                                  .shade600,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// EDIT BUTTON
                                    IconButton(
                                      icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20),
                                      onPressed: () async {
                                        Navigator.pop(
                                            ctx);

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddEditAddressScreen(
                                              address:
                                                  address,
                                            ),
                                          ),
                                        );

                                        addressCtrl.load(
                                            forceRefresh:
                                                true);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  /// ADD NEW ADDRESS BUTTON
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 10, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Add New Address",
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.w600),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Colors.green,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddEditAddressScreen(),
                            ),
                          );

                          addressCtrl.load(
                              forceRefresh: true);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

  /// ⭐ Logic: Verify if address is near current outlet
  Future<void> _verifyProximityAndProceed(
      BuildContext context, LocationData selectedAddress) async {
    try {
      final outletSocket = OutletSocketService.instance;
      final currentOutletId = CartController.instance.currentOutletId;

      if (outletSocket.cachedOutlets.isEmpty) {
        throw "Outlet data not available. Please wait.";
      }

      final currentOutlet = outletSocket.cachedOutlets.firstWhere(
        (o) => o.id == currentOutletId,
        orElse: () => outletSocket.cachedOutlets.first,
      );

      // Verify latitude/longitude mapping from your updated Outlet Model
      bool isNear = OutletVerificationService.isWithinRange(
        address: selectedAddress,
        currentOutletLat: currentOutlet.latitude.toString(),
        currentOutletLng: currentOutlet.longitude.toString(),
      );

      if (isNear) {
        final locCtrl = Provider.of<LocationController>(context, listen: false);
        await locCtrl.setSaved(selectedAddress);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutScreen(initialAddressId: selectedAddress.savedAddressId!),
          ),
        );
      } else {
        _showFarOutletDialog(context, selectedAddress);
      }
    } catch (e) {
      debugPrint("Verification Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// ⭐ Logic: Show alert for distant outlet
  void _showFarOutletDialog(BuildContext context, LocationData address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Outlet is Far Away"),
        content: const Text(
            "This outlet is too far from your selected address. We need to clear your cart so you can switch to a closer outlet."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // 1. Clear Cart
              CartController.instance.clear();
              
              // 2. Set new address globally
              final locCtrl = Provider.of<LocationController>(context, listen: false);
              await locCtrl.setSaved(address);
              
              // 3. Redirect Home
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            },
            child: const Text("Clear Cart & Go Home"),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REMAINING WIDGETS
// ---------------------------------------------------------------------------

class _CartImage extends StatelessWidget {
  final String path;
  const _CartImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    final url = UrlHelper.full(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            width: 70,
            height: 70,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey)),
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
          Icon(Icons.shopping_basket_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Your cart is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Add items to start ordering",
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}