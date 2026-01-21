import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../services/product_socket_service.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';
import '../widgets/product_add_button.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_price_view.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();

    // Initial product
    _product = widget.product;

    // Subscribe to realtime updates
    ProductSocketService.subscribe(_onProducts);

    // Ensure socket is connected
    ProductSocketService.connect();
  }

  @override
  void dispose() {
    ProductSocketService.unsubscribe(_onProducts);
    super.dispose();
  }

  /* ================= REALTIME HANDLER ================= */

  void _onProducts(List<Product> products) {
    if (!mounted) return;

    final updated = products
        .where((p) => p.id == _product.id)
        .toList();

    if (updated.isEmpty) return;

    setState(() {
      _product = updated.first;
    });
  }

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
          _product.name,
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ================= IMAGE GALLERY ================= */

            ProductImageGallery(
              key: ValueKey(_product.mainImage),
              mainImage: _product.mainImage,
              galleryImages: _product.galleryImages,
            ),

            const SizedBox(height: HomeSpacing.md),

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
                          _product.name,
                          style: HomeTextStyles.offerTitle,
                        ),
                      ),
                      if (_product.isTrending)
                        const _TrendingFireBadge(),
                    ],
                  ),

                  const SizedBox(height: HomeSpacing.sm),

                  /* PRICE */

                  ProductPriceView(
                    product: _product,
                    showDiscountText: false,
                  ),

                  const SizedBox(height: HomeSpacing.md),

                  /* SHORT DESCRIPTION */

                  if (_product.shortDescription != null &&
                      _product.shortDescription!
                          .trim()
                          .isNotEmpty)
                    Text(
                      _product.shortDescription!,
                      style: HomeTextStyles.body,
                    ),

                  const SizedBox(height: HomeSpacing.lg),

                  /* LONG DESCRIPTION */

                  if (_product.longDescription != null &&
                      _product.longDescription!
                          .trim()
                          .isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: HomeTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product.longDescription!,
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

      /* ================= BOTTOM BAR ================= */

      bottomNavigationBar: _BottomAddBar(product: _product),
    );
  }
}

/* ================================================= */
/* BOTTOM ADD BAR                                    */
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
/* TRENDING BADGE                                    */
/* ================================================= */

class _TrendingFireBadge extends StatelessWidget {
  const _TrendingFireBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
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
