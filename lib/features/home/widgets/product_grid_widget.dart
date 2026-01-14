import 'package:flutter/material.dart';

import '../models/product.model.dart';
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,

        // 🔥 CRITICAL FIX — more vertical room
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
        );
      },
    );
  }
}
