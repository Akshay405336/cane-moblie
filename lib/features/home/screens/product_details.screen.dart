import 'package:flutter/material.dart';

import '../models/product.model.dart';
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
      appBar: AppBar(
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ================= IMAGE GALLERY ================= */

            ProductImageGallery(
              mainImage: product.mainImage,
              galleryImages: product.galleryImages,
            ),

            const SizedBox(height: 16),

            /* ================= PRODUCT INFO ================= */

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  /* NAME + TRENDING */

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (product.isTrending)
                        _TrendingBadge(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /* PRICE */

                  ProductPriceView(product: product),

                  const SizedBox(height: 16),

                  /* SHORT DESCRIPTION */

                  if (product.shortDescription != null &&
                      product.shortDescription!
                          .trim()
                          .isNotEmpty)
                    Text(
                      product.shortDescription!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 20),

                  /* LONG DESCRIPTION */

                  if (product.longDescription != null &&
                      product.longDescription!
                          .trim()
                          .isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.longDescription!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
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
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
