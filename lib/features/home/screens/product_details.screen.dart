import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';
import '../widgets/product_add_button.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_price_view.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.pureWhite,

      /* ================= APP BAR ================= */

      appBar: AppBar(
        backgroundColor: HomeColors.greenPastry,
        elevation: 0,
        centerTitle: true,
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HomeTextStyles.sectionTitle,
        ),
        iconTheme: const IconThemeData(
          color: HomeColors.primaryGreen,
        ),
      ),

      /* ================= CONTENT ================= */

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 120, // ✅ space for bottom bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ================= IMAGE GALLERY ================= */

            ProductImageGallery(
              mainImage: product.mainImage,
              galleryImages: product.galleryImages,
            ),

            const SizedBox(height: HomeSpacing.md),

            /* ================= PRODUCT INFO ================= */

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* NAME + TRENDING */

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: HomeTextStyles.offerTitle,
                        ),
                      ),
                      if (product.isTrending)
                        const _TrendingFireBadge(),
                    ],
                  ),

                  const SizedBox(height: HomeSpacing.sm),

                  /* PRICE (NO DISCOUNT TEXT HERE) */

                  ProductPriceView(
                    product: product,
                    showDiscountText: false,
                  ),

                  const SizedBox(height: HomeSpacing.md),

                  /* SHORT DESCRIPTION */

                  if (product.shortDescription != null &&
                      product.shortDescription!.trim().isNotEmpty)
                    Text(
                      product.shortDescription!,
                      style: HomeTextStyles.body,
                    ),

                  const SizedBox(height: HomeSpacing.lg),

                  /* LONG DESCRIPTION */

                  if (product.longDescription != null &&
                      product.longDescription!.trim().isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: HomeTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.longDescription!,
                      style: HomeTextStyles.bodyGrey.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      /* ================= BOTTOM ADD BAR ================= */

      bottomNavigationBar: _BottomAddBar(product: product),
    );
  }
}

/* ================================================= */
/* BOTTOM ADD BAR (ZEPTO STYLE – CONSISTENT)          */
/* ================================================= */

class _BottomAddBar extends StatelessWidget {
  final Product product;

  const _BottomAddBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: HomeColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProductPriceView(
            product: product,
            showDiscountText: true,
          ),
          const ProductAddButton(),
        ],
      ),
    );
  }
}

/* ================================================= */
/* TRENDING FIRE BADGE (MATCH CARD STYLE)             */
/* ================================================= */

class _TrendingFireBadge extends StatelessWidget {
  const _TrendingFireBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.local_fire_department,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}
