import 'package:flutter/material.dart';
import '../../auth/state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../state/local_cart_controller.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/empty_cart_view.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Refresh cart data immediately when user opens this page
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
        title: const Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: AnimatedBuilder(
        animation: AuthController.instance,
        builder: (context, _) {
          final isLoggedIn = AuthController.instance.isLoggedIn;
          final Listenable listenable = isLoggedIn ? CartController.instance : LocalCartController.instance;

          return AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final server = CartController.instance;
              final local = LocalCartController.instance;

              final items = isLoggedIn ? server.items : local.items;
              final isLoading = isLoggedIn && server.isLoading;
              final total = isLoggedIn ? server.grandTotal : local.items.fold<double>(0, (sum, e) => sum + e.total);

              // 1. If we are currently fetching data from backend, show loader
              if (isLoading && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. If loading is done AND items are still empty, show empty view
              if (items.isEmpty && !isLoading) {
                return const EmptyCartView();
              }

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => CartItemCard(
                                key: ValueKey(items[index].productId),
                                item: items[index],
                                isLoggedIn: isLoggedIn,
                              ),
                              childCount: items.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckoutBottomBar(
                    itemCount: items.length,
                    grandTotal: total,
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