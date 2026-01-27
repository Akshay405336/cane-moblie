import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';
import '../models/cart_item.model.dart';

import '../../auth/state/auth_controller.dart';
import '../../../utils/auth_required_action.dart';
import '../../../routes.dart';
import '../../../core/network/url_helper.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (_, __) {
        final isLoggedIn = AuthController.instance.isLoggedIn;

        final ValueListenable listenable =
            isLoggedIn ? CartController.instance : LocalCartController.instance;

        return ValueListenableBuilder(
          valueListenable: listenable,
          builder: (_, __, ___) {
            final server = CartController.instance;
            final local = LocalCartController.instance;

            final items =
                isLoggedIn ? server.items : local.items;

            final itemCount =
                isLoggedIn ? server.itemCount : local.itemCount;

            /// ⭐ FIX: local total calc
            final grandTotal = isLoggedIn
                ? server.grandTotal
                : local.items.fold<double>(
                    0,
                    (sum, e) => sum + e.total,
                  );

            /* ================= LOADING ================= */

            if (isLoggedIn && server.isLoading && items.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            /* ================= EMPTY ================= */

            if (items.isEmpty) {
              return const _EmptyCartView();
            }

            return Column(
              children: [
                /* ================= ITEMS LIST ================= */

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];

                      return _CartTile(
                        item: item,
                        isLoggedIn: isLoggedIn,
                        loading: server.isLoading,
                      );
                    },
                  ),
                ),

                /* ================= BOTTOM BAR ================= */

                _BottomBar(
                  isLoggedIn: isLoggedIn,
                  itemCount: itemCount,
                  grandTotal: grandTotal,
                  loading: server.isLoading,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

class _CartTile extends StatelessWidget {
  final CartItem item;
  final bool isLoggedIn;
  final bool loading;

  const _CartTile({
    required this.item,
    required this.isLoggedIn,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 6, horizontal: 8),

      leading: _CartImage(path: item.image),

      title: Text(
        item.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      /// ⭐ SAFE total
      subtitle: Text(
        '₹${item.total.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      trailing: _QtyControls(
        item: item,
        isLoggedIn: isLoggedIn,
        loading: loading,
      ),
    );
  }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

class _QtyControls extends StatelessWidget {
  final CartItem item;
  final bool isLoggedIn;
  final bool loading;

  const _QtyControls({
    required this.item,
    required this.isLoggedIn,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: loading
              ? null
              : () {
                  final newQty = item.quantity - 1;

                  if (isLoggedIn) {
                    CartController.instance
                        .updateQty(item.productId, newQty);
                  } else {
                    LocalCartController.instance
                        .updateQty(item.productId, newQty);
                  }
                },
          icon: const Icon(Icons.remove_circle_outline),
        ),

        Text('${item.quantity}'),

        IconButton(
          onPressed: loading
              ? null
              : () {
                  final newQty = item.quantity + 1;

                  if (isLoggedIn) {
                    CartController.instance
                        .updateQty(item.productId, newQty);
                  } else {
                    LocalCartController.instance
                        .updateQty(item.productId, newQty);
                  }
                },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

class _BottomBar extends StatelessWidget {
  final bool isLoggedIn;
  final int itemCount;
  final double grandTotal;
  final bool loading;

  const _BottomBar({
    required this.isLoggedIn,
    required this.itemCount,
    required this.grandTotal,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text('Items: $itemCount'),
              Text(
                '₹${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      await AuthRequiredAction.run(
                        context,
                        action: () async {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.checkout,
                          );
                        },
                      );
                    },
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLoggedIn
                          ? 'Continue to Checkout'
                          : 'Login to Continue',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

class _CartImage extends StatelessWidget {
  final String path;

  const _CartImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    final url = UrlHelper.full(path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Your cart is empty 🍹',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
