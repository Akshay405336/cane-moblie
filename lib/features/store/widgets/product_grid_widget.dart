import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../../home/theme/home_spacing.dart';
import 'product_card.dart';

/// =================================================
/// Professional Product Grid (Sliver)
/// 
/// Improvements:
/// 1. Uses [SliverGrid] for high performance (Lazy loading).
/// 2. Uses [MaxCrossAxisExtent] for responsiveness (Works on tablets too).
/// 3. Standardized aspect ratio for grocery apps.
/// =================================================
class ProductGridWidget extends StatelessWidget {
  final List<Product> products;
  final String outletId;

  const ProductGridWidget({
    super.key,
    required this.products,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    // If empty, Slivers require a widget that takes up no space but is still a sliver.
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      sliver: SliverGrid(
        key: const PageStorageKey('product-grid'),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductCard(
              key: ValueKey(product.id), 
              product: product,
              outletId: outletId,
            );
          },
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          // ⭐ RESPONSIVE:
          // Instead of fixing count to 2, we say "items should be max 200px wide".
          // On mobile: fits 2 items. On tablet: fits 3 or 4 items automatically.
          maxCrossAxisExtent: 220,
          
          mainAxisSpacing: HomeSpacing.md,
          crossAxisSpacing: HomeSpacing.md,

          // ⭐ ASPECT RATIO: 
          // 0.65 - 0.70 is standard for grocery cards (Image + Title + Unit + Price/Btn)
          childAspectRatio: 0.68, 
        ),
      ),
    );
  }
}