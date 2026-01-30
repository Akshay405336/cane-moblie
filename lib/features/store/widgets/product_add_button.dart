import 'package:flutter/material.dart';

import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

import '../../auth/state/auth_controller.dart';
import '../../cart/state/local_cart_controller.dart';
import '../../cart/state/cart_controller.dart';

import '../models/product.model.dart';

class ProductAddButton extends StatefulWidget {
  final Product product;
  final String outletId;
  final VoidCallback? onTap;

  const ProductAddButton({
    super.key,
    required this.product,
    required this.outletId,
    this.onTap,
  });

  @override
  State<ProductAddButton> createState() => _ProductAddButtonState();
}

class _ProductAddButtonState extends State<ProductAddButton> {
  bool _localLoading = false;

  /// Helper to get current quantity based on Auth state
  int _getCurrentQty() {
    final isLoggedIn = AuthController.instance.isLoggedIn;
    final productId = widget.product.id;

    if (isLoggedIn) {
      // Check Server Cart
      final cart = CartController.instance.value;
      // We use .firstWhere with orElse to handle "not found" safely
      try {
        final item = cart.items.firstWhere((i) => i.productId == productId);
        return item.quantity;
      } catch (e) {
        return 0;
      }
    } else {
      // Check Local Cart
      final items = LocalCartController.instance.value;
      try {
        final item = items.firstWhere((i) => i.productId == productId);
        return item.quantity;
      } catch (e) {
        return 0;
      }
    }
  }

  /* ================================================= */
  /* ACTIONS                                           */
  /* ================================================= */

  Future<void> _updateQty(int newQty) async {
    if (_localLoading) return;
    setState(() => _localLoading = true);

    final isLoggedIn = AuthController.instance.isLoggedIn;
    final product = widget.product;

    try {
      if (isLoggedIn) {
        /* ================= SERVER CART UPDATE ================= */
        // If we are adding for the first time (qty 0 -> 1), use addItem
        // otherwise use updateQty for increment/decrement
        if (newQty == 1 && _getCurrentQty() == 0) {
          await CartController.instance.addItem(
            outletId: widget.outletId,
            productId: product.id,
            quantity: 1,
          );
        } else {
          await CartController.instance.updateQty(product.id, newQty);
        }
      } else {
        /* ================= LOCAL CART UPDATE ================= */
        // For local cart, updateQty handles both remove (if 0) and update
        // But if it's a new item (qty 0 -> 1), we must use addItem because
        // updateQty in LocalCartController requires the item to exist.
        
        if (newQty == 1 && _getCurrentQty() == 0) {
           LocalCartController.instance.addItem(
            productId: product.id,
            name: product.name,
            image: product.mainImageUrl,
            unitPrice: product.originalPrice,
            discountPrice: product.discountPrice,
            quantity: 1,
          );
        } else {
          LocalCartController.instance.updateQty(product.id, newQty);
        }
      }

      widget.onTap?.call();
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to BOTH controllers. If either updates, the button rebuilds.
    return AnimatedBuilder(
      animation: Listenable.merge([
        CartController.instance,
        LocalCartController.instance,
      ]),
      builder: (context, _) {
        final qty = _getCurrentQty();
        final isGlobalLoading = CartController.instance.isLoading;
        
        // Prevent interaction if global cart is syncing or local button is processing
        final isLoading = _localLoading || (isGlobalLoading && qty > 0); 
        // Note: We allow minor loading blocking only on the specific item if desired, 
        // but here we block if *this* specific action triggered it.

        if (qty > 0) {
          /* ------------------------------------------------ */
          /* CASE 1: ITEM IS IN CART -> SHOW COUNTER          */
          /* ------------------------------------------------ */
          return Container(
            height: 32,
            constraints: const BoxConstraints(minWidth: 80),
            decoration: BoxDecoration(
              color: HomeColors.primaryGreen, // Active background
              borderRadius: BorderRadius.circular(HomeSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DECREMENT BUTTON
                _IconBtn(
                  icon: Icons.remove,
                  onTap: isLoading ? null : () => _updateQty(qty - 1),
                ),

                // QTY TEXT
                SizedBox(
                  width: 20, // Fixed width for stability
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 10, 
                            width: 10, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: Colors.white
                            )
                          )
                        )
                      : Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: HomeTextStyles.addButton.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                // INCREMENT BUTTON
                _IconBtn(
                  icon: Icons.add,
                  onTap: isLoading ? null : () => _updateQty(qty + 1),
                ),
              ],
            ),
          );
        }

        /* ------------------------------------------------ */
        /* CASE 2: ITEM NOT IN CART -> SHOW + ADD BUTTON    */
        /* ------------------------------------------------ */
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(HomeSpacing.radiusSm),
            onTap: isLoading ? null : () => _updateQty(1),
            child: Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 64),
              padding: const EdgeInsets.symmetric(
                horizontal: HomeSpacing.sm,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomeColors.pureWhite,
                borderRadius: BorderRadius.circular(HomeSpacing.radiusSm),
                border: Border.all(
                  color: HomeColors.primaryGreen,
                  width: 1.2,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HomeColors.primaryGreen,
                      ),
                    )
                  : Text(
                      '+ ADD',
                      style: HomeTextStyles.addButton,
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Small helper widget for the +/- buttons to keep code clean
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}