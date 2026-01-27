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
  State<ProductAddButton> createState() =>
      _ProductAddButtonState();
}

class _ProductAddButtonState
    extends State<ProductAddButton> {
  bool _loading = false;

  /* ================================================= */
  /* ADD FLOW                                          */
  /* ================================================= */

  Future<void> _add() async {
    if (_loading) return;

    setState(() => _loading = true);

    final product = widget.product;
    final isLoggedIn =
        AuthController.instance.isLoggedIn;

    try {
      if (isLoggedIn) {
        /* ================= SERVER CART ================= */

        await CartController.instance.addItem(
          outletId: widget.outletId,
          productId: product.id,
          quantity: 1,
        );
      } else {
        /* ================= LOCAL CART ================= */

        LocalCartController.instance.addItem(
          productId: product.id,
          name: product.name,

          /// ✅ correct fields
          image: product.mainImageUrl,
          unitPrice: product.originalPrice,
          discountPrice: product.discountPrice,

          quantity: 1,
        );
      }

      widget.onTap?.call();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(HomeSpacing.radiusSm),
        onTap: _loading ? null : _add,
        child: Container(
          height: 32,
          constraints: const BoxConstraints(minWidth: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.sm,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HomeColors.pureWhite,
            borderRadius:
                BorderRadius.circular(HomeSpacing.radiusSm),
            border: Border.all(
              color: HomeColors.primaryGreen,
              width: 1.2,
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  '+ ADD',
                  style: HomeTextStyles.addButton,
                ),
        ),
      ),
    );
  }
}
