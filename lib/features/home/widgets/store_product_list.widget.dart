import 'package:flutter/material.dart';

// MODELS
import '../../store/models/outlet.model.dart';
import '../../store/models/product.model.dart';

// SERVICES
import '../../store/services/product_api.dart';

// WIDGETS
import '../../store/widgets/outlet_card.widget.dart';
import '../../store/widgets/product_add_button.dart'; // ⭐ IMPORTED YOUR BUTTON

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
          // Keep limit to 5 for performance
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
    if (!_loading && _products.isEmpty) {
      return OutletCard(outlet: widget.outlet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ================= MAIN STORE CARD ================= */
        OutletCard(outlet: widget.outlet),

        /* ================= PRODUCT PREVIEW LIST ================= */
        if (!_loading) ...[
          const SizedBox(height: 16), 
          
          SizedBox(
            height: 240, // Increased height slightly to fit the Add Button comfortably
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _MiniProductCard(
                  product: _products[index],
                  outletId: widget.outlet.id, // ⭐ Pass ID for the button
                );
              },
            ),
          ),
          
          const SizedBox(height: 8), 
        ]
        else if (_loading)
           const Padding(
             padding: EdgeInsets.only(top: 12, left: 16),
             child: SizedBox(
               height: 20, width: 20, 
               child: CircularProgressIndicator(strokeWidth: 2)
             ),
           ),
      ],
    );
  }
}

/* ================================================= */
/* ⭐ PREMIUM MINI PRODUCT CARD (Using ProductAddButton) */
/* ================================================= */

class _MiniProductCard extends StatelessWidget {
  final Product product;
  final String outletId; 

  const _MiniProductCard({
    required this.product,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155, // ⭐ Made wider to fit the "Add" button properly
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
              /* ================= 1. IMAGE AREA ================= */
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HomeColors.lightGrey,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.mainImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /* ================= 2. CONTENT AREA ================= */
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HomeTextStyles.productName,
                    ),
                    
                    const SizedBox(height: 4),

                    // Unit
                    Text(
                      '${product.unit.value} ${product.unit.type}',
                      style: HomeTextStyles.unit,
                    ),

                    const SizedBox(height: 10),

                    // Price
                    Row(
                      children: [
                        Text(
                          '₹${product.displayPrice.toInt()}',
                          style: HomeTextStyles.price,
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${product.originalPrice.toInt()}',
                            style: HomeTextStyles.originalPrice,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          /* ================= 3. ADD BUTTON (Positioned) ================= */
          // ⭐ Replaced the manual icon with your full Logic Button
          Positioned(
            bottom: 8,
            right: 8,
            child: ProductAddButton(
              product: product,
              outletId: outletId,
              // Optional: Add a small callback if you want to refresh anything
              onTap: () {}, 
            ),
          ),

          /* ================= 4. DISCOUNT BADGE ================= */
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