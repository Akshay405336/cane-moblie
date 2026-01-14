import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../screens/product_details.screen.dart';
import 'product_price_view.dart';

/// Single product card
/// Used inside ProductGridWidget
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ================= IMAGE ================= */

            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.mainImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.isTrending)
                  const _TrendingBadge(),
              ],
            ),

            /* ================= DETAILS ================= */

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                10, // ✅ slightly reduced bottom padding
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2, // ✅ CRITICAL FIX
                    ),
                  ),

                  const SizedBox(height: 6),

                  ProductPriceView(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* TRENDING BADGE                                    */
/* ================================================= */

class _TrendingBadge extends StatelessWidget {
  const _TrendingBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Trending',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
