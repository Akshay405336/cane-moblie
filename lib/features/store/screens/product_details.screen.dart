import 'package:flutter/material.dart';

// THEME
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

// MODELS
import '../models/product.model.dart';
import '../../cart/models/cart.model.dart'; // ⭐ Added for Cart Logic

// CONTROLLERS
import '../../auth/state/auth_controller.dart'; // ⭐ Added
import '../../cart/state/cart_controller.dart'; // ⭐ Added
import '../../cart/state/local_cart_controller.dart'; // ⭐ Added

// SCREENS
import '../../checkout/screens/checkout_screen.dart'; // ⭐ Added

// UTILS
import '../../../utils/auth_required_action.dart'; // ⭐ Added

// WIDGETS
import '../widgets/product_add_button.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_price_view.dart';

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
      
      // --- APP BAR ---
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

      // --- BODY WITH STACK (For Floating Cart Bar) ---
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Image Gallery
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

              // Content Details
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
                    
                    // Extra space at bottom so text isn't hidden by the floating bars
                    const SizedBox(height: 120), 
                  ]),
                ),
              ),
            ],
          ),

          // 2. FLOATING CART BAR (⭐ NEW)
          // It sits at bottom: 0 of the body, which is right above the bottomNavigationBar
          const Positioned(
            bottom: 0, 
            left: 0, 
            right: 0,
            child: _ViewCartFloatingBar(),
          ),
        ],
      ),

      // --- BOTTOM BAR (Add to Cart) ---
      bottomNavigationBar: _BottomAddBar(
        product: _product,
        outletId: widget.outletId,
      ),
    );
  }
}

/* ================================================= */
/* FLOATING CART BAR (⭐ NEW)                        */
/* ================================================= */

class _ViewCartFloatingBar extends StatelessWidget {
  const _ViewCartFloatingBar();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthController.instance.isLoggedIn;
    
    // Listen to Cart changes
    return ValueListenableBuilder(
      valueListenable: isLoggedIn ? CartController.instance : LocalCartController.instance,
      builder: (context, cartValue, _) {
        int itemCount = 0;
        double totalPrice = 0;

        // Calculate totals
        if (isLoggedIn && cartValue is Cart) {
          itemCount = cartValue.itemCount;
          totalPrice = cartValue.grandTotal;
        } else {
          final items = LocalCartController.instance.items;
          itemCount = items.fold(0, (sum, item) => sum + item.quantity);
          totalPrice = items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
        }

        // Hide if empty
        if (itemCount == 0) return const SizedBox.shrink();

        // Show the floating bar
        return Container(
          // Margin ensures it floats slightly above the bottom "Add" bar
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            onTap: () async {
              await AuthRequiredAction.run(context, action: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
              });
            },
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
}

/* ================================================= */
/* SECTIONS (Unchanged)                              */
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
    // This bar is fixed at the bottom of the screen
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