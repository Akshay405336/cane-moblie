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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeSpacing.sm),

        /// ===== HEADER =====
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fresh Products',
                style: HomeTextStyles.sectionTitle,
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View all',
                  style: HomeTextStyles.bodyGrey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: HomeSpacing.md),

        /// ===== CONTENT =====
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: HomeSpacing.md,
            ),
            child: ProductShimmerWidget(),
          )
        else
          ProductGridWidget(
            products: products.length > 6
                ? products.take(6).toList() // 👈 Home preview
                : products,
          ),
      ],
    );
  }
}
