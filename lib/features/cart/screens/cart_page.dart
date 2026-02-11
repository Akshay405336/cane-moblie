import 'package:caneandtender/features/cart/widgets/cart_item_card.dart';
import 'package:caneandtender/features/cart/widgets/checkout_bottom_bar.dart';
import 'package:caneandtender/features/cart/widgets/empty_cart_view.dart';
import 'package:flutter/material.dart';
import '../../auth/state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    if (AuthController.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CartController.instance.load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: AnimatedBuilder(
        animation: AuthController.instance,
        builder: (_, __) {
          final isLoggedIn = AuthController.instance.isLoggedIn;
          final Listenable listenable = isLoggedIn
              ? CartController.instance
              : LocalCartController.instance;

          return AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final server = CartController.instance;
              final local = LocalCartController.instance;

              final items = isLoggedIn ? server.items : local.items;
              final isLoading = isLoggedIn && server.isLoading;
              final grandTotal = isLoggedIn
                  ? server.grandTotal
                  : local.items.fold<double>(0, (sum, e) => sum + e.total);

              if (isLoading && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (items.isEmpty) {
                return const EmptyCartView();
              }

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = items[index];
                                return CartItemCard(
                                  key: ValueKey(item.productId),
                                  item: item,
                                  isLoggedIn: isLoggedIn,
                                );
                              },
                              childCount: items.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckoutBottomBar(
                    itemCount: items.length,
                    grandTotal: grandTotal,
                    isLoggedIn: isLoggedIn,
                    loading: isLoading,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}