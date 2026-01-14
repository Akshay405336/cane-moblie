import 'package:flutter/material.dart';

import '../models/product.model.dart';

/// Product price view
/// Used in:
/// - ProductCard
/// - ProductDetailsScreen
class ProductPriceView extends StatelessWidget {
  final Product product;

  const ProductPriceView({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        /* ===== DISPLAY PRICE ===== */

        Text(
          '₹${product.displayPrice.toStringAsFixed(0)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
          ),
        ),

        /* ===== ORIGINAL PRICE (STRIKE) ===== */

        if (product.hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            '₹${product.originalPrice.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ],

        /* ===== DISCOUNT BADGE (OPTIONAL) ===== */

        if (product.hasDiscount) ...[
          const SizedBox(width: 6),
          _DiscountBadge(
            percent: product.discountPercent,
          ),
        ],
      ],
    );
  }
}

/* ================================================= */
/* DISCOUNT BADGE                                    */
/* ================================================= */

class _DiscountBadge extends StatelessWidget {
  final int percent;

  const _DiscountBadge({
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '-$percent%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}
