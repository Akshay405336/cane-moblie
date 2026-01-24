import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../../home/theme/home_spacing.dart';
import 'product_card.dart';

/// =================================================
/// Product grid (2-column)
/// Used in:
/// - OutletProductsScreen
/// =================================================
class ProductGridWidget extends StatelessWidget {
  final List<Product> products;

  /// outlet context (needed for socket + navigation)
  final String outletId;

  const ProductGridWidget({
    super.key,
    required this.products,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(); // clean empty
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

        /// grocery style spacing
        mainAxisSpacing: HomeSpacing.md,
        crossAxisSpacing: HomeSpacing.md,

        /// card height tuning
        childAspectRatio: 0.64,
      ),
      itemBuilder: (_, index) {
        final product = products[index];

        return ProductCard(
          key: ValueKey(product.id), // stable during realtime updates
          product: product,
          outletId: outletId, // ⭐ pass outlet
        );
      },
    );
  }
}
