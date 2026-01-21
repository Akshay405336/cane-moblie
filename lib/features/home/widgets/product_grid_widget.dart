import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../theme/home_spacing.dart';
import 'product_card.dart';

/// Product grid (2-column)
/// Used in:
/// - HomeScreen
/// - ProductsScreen
class ProductGridWidget extends StatelessWidget {
  final List<Product> products;

  const ProductGridWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      key: const PageStorageKey('product-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      itemCount: products.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        // Clean grocery spacing
        mainAxisSpacing: HomeSpacing.md,
        crossAxisSpacing: HomeSpacing.md,

        // ✅ hugs card perfectly
        childAspectRatio: 0.64,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          key: ValueKey(product.id), // 🔒 stable during realtime updates
          product: product,
        );
      },
    );
  }
}
