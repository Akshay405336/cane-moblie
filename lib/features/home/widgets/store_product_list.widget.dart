import 'package:caneandtender/features/store/screens/outlet_products_screen.dart';
import 'package:caneandtender/features/store/screens/product_details.screen.dart';
import 'package:flutter/material.dart';


// MODELS
import '../../store/models/outlet.model.dart';
import '../../store/models/product.model.dart';

// SERVICES
import '../../store/services/product_api.dart';

// WIDGETS
import '../../store/widgets/product_add_button.dart';

// THEME
import '../theme/home_colors.dart';
import '../theme/home_text_styles.dart';

class StoreWithProductsWidget extends StatefulWidget {
  final Outlet outlet;

  const StoreWithProductsWidget({
    super.key,
    required this.outlet,
  });

  @override
  State<StoreWithProductsWidget> createState() => _StoreWithProductsWidgetState();
}

class _StoreWithProductsWidgetState extends State<StoreWithProductsWidget> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final allProducts = await ProductApi.getByOutlet(widget.outlet.id);
      if (mounted) {
        setState(() {
          _products = allProducts.take(5).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading products for store: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ================= PREMIUM OUTLET HEADER DESIGN ================= */
        _PremiumOutletHeader(
          outlet: widget.outlet,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OutletProductsScreen(outlet: widget.outlet),
              ),
            );
          },
        ),

        /* ================= PRODUCT PREVIEW LIST LOGIC ================= */
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 24),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(HomeColors.primaryGreen),
                ),
              ),
            ),
          )
        else if (_products.isEmpty)
          /* ================= ANIMATED NO PRODUCTS STATE ================= */
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: HomeColors.primaryGreen.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 32,
                              color: HomeColors.primaryGreen.withOpacity(0.4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No products available yet",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Check back later or explore other stores",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        else ...[
          /* ================= PRODUCT PREVIEW LIST ================= */
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _MiniProductCard(
                  product: _products[index],
                  outletId: widget.outlet.id,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/* ================================================= */
/* UPDATED PREMIUM OUTLET HEADER DESIGN             */
/* ================================================= */

class _PremiumOutletHeader extends StatelessWidget {
  final Outlet outlet;
  final VoidCallback onTap;

  const _PremiumOutletHeader({required this.outlet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String monogram = outlet.name.isNotEmpty ? outlet.name[0].toUpperCase() : 'S';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HomeColors.primaryGreen.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: HomeColors.primaryGreen.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                monogram,
                style: TextStyle(
                  color: HomeColors.primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text("Fresh & Fast", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 6),
                      Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text("Best Quality", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 2),
                      const Text("4.5", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_filled_rounded, size: 13, color: HomeColors.primaryGreen),
                      const SizedBox(width: 3),
                      const Text("25 mins", style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* MINI PRODUCT CARD - UPDATED WITH NAVIGATION      */
/* ================================================= */

class _MiniProductCard extends StatelessWidget {
  final Product product;
  final String outletId;

  const _MiniProductCard({required this.product, required this.outletId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: HomeColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeColors.divider),
        boxShadow: [
          BoxShadow(
            color: HomeColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ⭐ Wrap content in InkWell for navigation
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      product: product,
                      outletId: outletId,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: HomeColors.lightGrey,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      image: DecorationImage(
                        image: NetworkImage(product.mainImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: HomeTextStyles.productName,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.unit.value} ${product.unit.type}',
                          style: HomeTextStyles.unit,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '₹${product.displayPrice.toInt()}', 
                              style: HomeTextStyles.price.copyWith(color: HomeColors.primaryGreen)
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text('₹${product.originalPrice.toInt()}', style: HomeTextStyles.originalPrice),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // The Add button remains on top and handles its own clicks
            Positioned(
              bottom: 8,
              right: 8,
              child: ProductAddButton(
                product: product,
                outletId: outletId,
                onTap: () {},
              ),
            ),
            if (product.hasDiscount)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: HomeColors.discountRed,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${product.discountPercent}% OFF',
                    style: HomeTextStyles.discount,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}