import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// THEME
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

// MODELS
import '../models/product.model.dart';
import '../../cart/models/cart.model.dart';
import '../../location/models/location.model.dart';

// CONTROLLERS
import '../../auth/state/auth_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';
import '../../saved_address/state/saved_address_controller.dart';
import '../../location/state/location_controller.dart';

// SCREENS
import '../../checkout/screens/checkout_screen.dart';

// SERVICES
import '../services/outlet_socket_service.dart';
import '../services/outlet_verification_service.dart';

// UTILS
import '../../../utils/auth_required_action.dart';
import '../../../routes.dart';

// WIDGETS
import '../widgets/product_add_button.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_price_view.dart';
import '../../cart/widgets/address_selection_sheet.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String outletId;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.outletId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    debugPrint('🛒 ProductDetails → opened product: ${_product.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.pureWhite,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HomeTextStyles.sectionTitle.copyWith(
            color: HomeColors.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: HomeColors.primaryGreen,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HomeColors.greenPastry.withOpacity(0.8),
                HomeColors.greenPastry.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Hero(
                  tag: 'product-${_product.id}',
                  child: ProductImageGallery(
                    key: ValueKey(_product.mainImageUrl),
                    mainImageUrl: _product.mainImageUrl,
                    galleryImageUrls: _product.galleryImageUrls,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeSpacing.md,
                  vertical: HomeSpacing.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _HeaderSection(product: _product),
                    const SizedBox(height: HomeSpacing.md),
                    _PriceSection(product: _product),
                    const SizedBox(height: HomeSpacing.md),
                    
                    if (_product.tags.isNotEmpty) ...[
                      _TagSection(product: _product),
                      const SizedBox(height: HomeSpacing.lg),
                    ],

                    _DescriptionSection(product: _product),
                    const SizedBox(height: 150), 
                  ]),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0, 
            left: 0, 
            right: 0,
            child: _ViewCartFloatingBar(outletId: widget.outletId),
          ),
        ],
      ),

      bottomNavigationBar: _BottomAddBar(
        product: _product,
        outletId: widget.outletId,
      ),
    );
  }
}

/* ================================================= */
/* FLOATING CART BAR 								 */
/* ================================================= */

class _ViewCartFloatingBar extends StatelessWidget {
  final String outletId;
  const _ViewCartFloatingBar({required this.outletId});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthController.instance.isLoggedIn;
    
    return ValueListenableBuilder(
      valueListenable: isLoggedIn ? CartController.instance : LocalCartController.instance,
      builder: (context, cartValue, _) {
        int itemCount = 0;
        double totalPrice = 0;

        if (isLoggedIn && cartValue is Cart) {
          itemCount = cartValue.itemCount;
          totalPrice = cartValue.grandTotal;
        } else {
          final items = LocalCartController.instance.items;
          itemCount = items.fold(0, (sum, item) => sum + item.quantity);
          totalPrice = items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
        }

        if (itemCount == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: HomeColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _handleCheckoutValidation(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount ITEMS', 
                      style: const TextStyle(
                        color: Colors.white70, 
                        fontSize: 10, 
                        fontWeight: FontWeight.w600, 
                        letterSpacing: 0.5
                      )
                    ),
                    Text(
                      '₹${totalPrice.toStringAsFixed(0)}', 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 15, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'View Cart', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCheckoutValidation(BuildContext context) async {
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
      
      if (outletSocket.cachedOutlets.isEmpty) throw "Outlet data not available.";

      final currentOutlet = outletSocket.cachedOutlets.firstWhere(
        (o) => o.id == outletId,
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

/* ================================================= */
/* SECTIONS 										 */
/* ================================================= */

class _HeaderSection extends StatelessWidget {
  final Product product;
  const _HeaderSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.category.name.isNotEmpty)
        Text(
          product.category.name.toUpperCase(),
          style: HomeTextStyles.bodyGrey.copyWith(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: HomeTextStyles.offerTitle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (product.isTrending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Trending',
                      style: HomeTextStyles.bodyGrey.copyWith(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  final Product product;
  const _PriceSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProductPriceView(
              product: product,
              showDiscountText: true,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: HomeColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${product.unit.value} ${product.unit.type}',
                style: HomeTextStyles.bodyGrey.copyWith(
                  color: HomeColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  final Product product;
  const _TagSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.tags.map((tag) {
        return Chip(
          label: Text(tag, style: const TextStyle(fontSize: 12)),
          backgroundColor: HomeColors.greenPastry.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Product product;
  const _DescriptionSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final text = product.longDescription ?? product.shortDescription;
    if (text == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: HomeTextStyles.sectionTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: HomeTextStyles.bodyGrey.copyWith(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BottomAddBar extends StatelessWidget {
  final Product product;
  final String outletId;

  const _BottomAddBar({
    required this.product,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: HomeTextStyles.bodyGrey.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                ProductPriceView(
                  product: product,
                  showDiscountText: false,
                ),
              ],
            ),
            ProductAddButton(
              product: product,
              outletId: outletId,
            ),
          ],
        ),
      ),
    );
  }
}