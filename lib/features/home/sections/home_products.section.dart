import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeProductsSection extends StatelessWidget {
  final bool loading;
  final List<Product> products;
  final VoidCallback onViewAll;

  const HomeProductsSection({
    super.key,
    required this.loading,
    required this.products,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home-products-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeSpacing.sm),

        const _Header(),

        const SizedBox(height: HomeSpacing.md),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const Padding(
                  key: ValueKey('product-shimmer'),
                  padding: EdgeInsets.symmetric(
                    horizontal: HomeSpacing.md,
                  ),
                  child: ProductShimmerWidget(),
                )
              : ProductGridWidget(
                  key: const ValueKey('product-grid'),
                  products: products.length > 6
                      ? products.take(6).toList() // 👈 Home preview
                      : products,
                ),
        ),
      ],
    );
  }
}

/* ================================================= */
/* HEADER                                            */
/* ================================================= */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fresh Products',
            style: HomeTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {
              // This will be overridden by parent callback
              // Kept stateless & rebuild-safe
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'View all',
              style: HomeTextStyles.bodyGrey,
            ),
          ),
        ],
      ),
    );
  }
}
