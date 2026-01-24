import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../screens/product_details.screen.dart';
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  /// ⭐ outlet scoped
  final String outletId;

  const ProductCard({
    super.key,
    required this.product,
    required this.outletId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(HomeSpacing.radiusLg),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: product,
              outletId: outletId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: HomeColors.pureWhite,
          borderRadius:
              BorderRadius.circular(HomeSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(3, 7),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /* ================= IMAGE STACK ================= */

            Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(HomeSpacing.sm),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                            HomeSpacing.radiusMd),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Image.network(
                        product.mainImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (context, child, progress) {
                          if (progress == null)
                            return child;
                          return const Center(
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: HomeColors.primaryGreen,
                            ),
                          );
                        },
                        errorBuilder:
                            (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 28,
                            color:
                                HomeColors.textLightGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /* TRENDING BADGE */

                if (product.isTrending)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                /* ADD BUTTON */

                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10),
                    decoration: BoxDecoration(
                      color: HomeColors.pureWhite,
                      borderRadius:
                          BorderRadius.circular(6),
                      border: Border.all(
                        color: HomeColors.primaryGreen,
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+ ADD',
                      style: TextStyle(
                        color: HomeColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /* ================= DETAILS ================= */

            Padding(
              padding: const EdgeInsets.fromLTRB(
                HomeSpacing.sm,
                0,
                HomeSpacing.sm,
                0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GreenPricePill(
                        price: product.displayPrice,
                      ),
                      const SizedBox(width: 6),
                      if (product.hasDiscount)
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(0)}',
                          style: HomeTextStyles.originalPrice
                              .copyWith(
                            color: HomeColors.textGrey,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (product.hasDiscount)
                    Row(
                      children: [
                        Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: HomeColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(child: _DottedLine()),
                      ],
                    ),

                  const SizedBox(height: 4),

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HomeTextStyles.productName
                        .copyWith(height: 1.25),
                  ),

                  const SizedBox(height: 2),
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
/* GREEN PRICE PILL                                  */
/* ================================================= */

class _GreenPricePill extends StatelessWidget {
  final double price;

  const _GreenPricePill({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding:
          const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: HomeColors.primaryGreen,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '₹${price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/* ================================================= */
/* DOTTED LINE                                       */
/* ================================================= */

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount =
            (constraints.maxWidth / 6).floor();

        return Row(
          children: List.generate(
            dashCount,
            (_) => Expanded(
              child: Container(
                height: 1,
                margin:
                    const EdgeInsets.symmetric(horizontal: 1),
                color: HomeColors.primaryGreen
                    .withOpacity(0.4),
              ),
            ),
          ),
        );
      },
    );
  }
}
