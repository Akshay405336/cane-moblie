import 'package:flutter/material.dart';
import '../models/cart_item.model.dart';
import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';
import '../../../core/network/url_helper.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isLoggedIn;

  // FIX: Use the standard constructor format. 
  // This passes the key to the super constructor correctly.
  const CartItemCard({
    super.key, 
    required this.item, 
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            offset: const Offset(0, 4), 
            blurRadius: 12,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          // FIX: Use a value-based key unique to the product.
          // Do not just use 'key' (which refers to the widget itself).
          key: ValueKey('dismiss_${item.productId}'), 
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color(0xFFFFE5E5),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) {
            if (isLoggedIn) {
              CartController.instance.updateQty(item.productId, 0);
            } else {
              LocalCartController.instance.updateQty(item.productId, 0);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _CartImage(path: item.image),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name, 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${item.total.toStringAsFixed(0)}', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          _QtyControl(
                            qty: item.quantity,
                            onChanged: (val) {
                              if (val < 1) return; 
                              if (isLoggedIn) {
                                CartController.instance.updateQty(item.productId, val);
                              } else {
                                LocalCartController.instance.updateQty(item.productId, val);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item?"),
        content: const Text("Are you sure you want to remove this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final Function(int) onChanged;
  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          _Icon(Icons.remove, () => onChanged(qty - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), 
            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          _Icon(Icons.add, () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Icon(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, 
      child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(icon, size: 16)),
    );
  }
}

class _CartImage extends StatelessWidget {
  final String path;
  const _CartImage({required this.path});
  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const Icon(Icons.image_not_supported);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        UrlHelper.full(path), 
        width: 70, 
        height: 70, 
        fit: BoxFit.cover,
      ),
    );
  }
}