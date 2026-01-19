import 'package:flutter/material.dart';
import '../models/product.model.dart';
import '../theme/home_colors.dart';
import '../theme/home_text_styles.dart';

/// Product price view
/// Used in:
/// - ProductCard
/// - ProductDetailsScreen
class ProductPriceView extends StatelessWidget {
  final Product product;
  final bool showDiscountText;

  const ProductPriceView({
    super.key,
    required this.product,
    this.showDiscountText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /* ================= PRICE ROW ================= */

        Row(
          children: [
            _GreenPricePill(
              price: product.displayPrice,
            ),
            const SizedBox(width: 6),
            if (product.hasDiscount)
              Text(
                '₹${product.originalPrice.toStringAsFixed(0)}',
                style: HomeTextStyles.originalPrice.copyWith(
                  color: HomeColors.textGrey,
                ),
              ),
          ],
        ),

        /* ================= DISCOUNT ================= */

        if (showDiscountText && product.hasDiscount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${product.discountPercent}% OFF',
              style: HomeTextStyles.body.copyWith(
                color: HomeColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: HomeColors.primaryGreen,
        borderRadius: BorderRadius.circular(6),
      ),
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
