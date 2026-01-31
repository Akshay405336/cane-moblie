import 'package:flutter/material.dart';
import '../models/product.model.dart';
import '../../home/theme/home_colors.dart';

class MiniProductCard extends StatelessWidget {
  final Product product;

  const MiniProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, // Fixed width for horizontal list
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ================= IMAGE ================= */
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                image: DecorationImage(
                  image: NetworkImage(product.mainImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /* ================= INFO ================= */
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),

                // UNIT (e.g., "1 kg")
                Text(
                  '${product.unit.value} ${product.unit.type}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 6),

                // PRICE
                Row(
                  children: [
                    Text(
                      '₹${product.displayPrice.toInt()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: HomeColors.primaryGreen,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 4),
                      Text(
                        '₹${product.originalPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}