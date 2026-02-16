import 'package:caneandtender/features/store/screens/outlet_products_screen.dart';
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
        /* ================= PREMIUM OUTLET NAME DESIGN ================= */
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

        /* ================= PRODUCT PREVIEW LIST ================= */
        if (!_loading && _products.isNotEmpty) ...[
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
        ] else if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 12, left: 16),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(HomeColors.primaryGreen),
              ),
            ),
          ),
      ],
    );
  }
}

/* ================================================= */
/* PREMIUM OUTLET HEADER DESIGN                      */
/* ================================================= */

class _PremiumOutletHeader extends StatelessWidget {
  final Outlet outlet;
  final VoidCallback onTap;

  const _PremiumOutletHeader({required this.outlet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get the first letter for the monogram
    String monogram = outlet.name.isNotEmpty ? outlet.name[0].toUpperCase() : 'S';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HomeColors.primaryGreen.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: HomeColors.primaryGreen.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // PREMIUM MONOGRAM BADGE (Replaced Icon)
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HomeColors.primaryGreen,
                    HomeColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: HomeColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                monogram,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: HomeColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "TRUSTED STORE",
                          style: TextStyle(
                            fontSize: 10,
                            color: HomeColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified_rounded, size: 14, color: Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HomeColors.primaryGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded, 
                size: 14, 
                color: HomeColors.primaryGreen
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* MINI PRODUCT CARD                                 */
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
      child: Stack(
        children: [
          Column(
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
    );
  }
}