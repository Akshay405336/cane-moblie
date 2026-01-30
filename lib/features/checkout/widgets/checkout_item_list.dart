import 'package:flutter/material.dart';
import '../models/checkout_summary.model.dart'; // Import your model
import '../../../core/network/url_helper.dart';

class CheckoutItemList extends StatelessWidget {
  final List<CheckoutItem> items;

  const CheckoutItemList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            "Items in Cart",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (ctx, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _ProductThumb(url: item.productImage),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qty: ${item.quantity}",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Text(
                      "₹${item.lineTotal}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Private helper for image
class _ProductThumb extends StatelessWidget {
  final String url;
  const _ProductThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey));
    }
    return Image.network(
      UrlHelper.full(url),
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
    );
  }
}