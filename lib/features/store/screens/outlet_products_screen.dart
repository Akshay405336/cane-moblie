import 'package:flutter/material.dart';

// THEME & UTILS
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

// MODELS
import '../models/product.model.dart';
import '../models/outlet.model.dart';
import '../../cart/models/cart.model.dart'; // Needed for type check

// CONTROLLERS
import '../../auth/state/auth_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';

// SCREENS
import '../../checkout/screens/checkout_screen.dart'; // ✅ Import Checkout Screen

// SERVICES
import '../services/product_socket_service.dart';

// UTILS
import '../../../utils/auth_required_action.dart'; // ✅ Import Auth Action

// WIDGETS
import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';

class OutletProductsScreen extends StatefulWidget {
  final Outlet outlet;

  const OutletProductsScreen({
    super.key,
    required this.outlet,
  });

  @override
  State<OutletProductsScreen> createState() => _OutletProductsScreenState();
}

class _OutletProductsScreenState extends State<OutletProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;

  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    debugPrint('🛒 Products screen opened → outlet=${widget.outlet.id}');

    /// Subscribe first
    ProductSocketService.subscribe(_onProducts);

    /// Fetch via REST (internally)
    ProductSocketService.connect(widget.outlet.id);
  }

  /* ================================================= */
  /* PRODUCTS HANDLER                                  */
  /* ================================================= */

  void _onProducts(List<Product> products) {
    if (!mounted) return;

    debugPrint('🛒 Products received → count=${products.length}');

    setState(() {
      _products = products;
      _loading = false;
    });
  }

  /* ================================================= */
  /* DISPOSE                                           */
  /* ================================================= */

  @override
  void dispose() {
    ProductSocketService.unsubscribe(_onProducts);
    super.dispose();
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🎨 Products build → loading=$_loading products=${_products.length}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Light grey background
      appBar: AppBar(
        title: Text(widget.outlet.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      
      // ✅ BODY
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ProductShimmerWidget(),
            )
          : _products.isEmpty
              ? const Center(
                  child: Text('No products available'),
                )
              : ProductGridWidget(
                  products: _products,
                  outletId: widget.outlet.id,
                ),

      // ✅ BOTTOM BAR (Updated for Direct Checkout)
      bottomNavigationBar: const _ViewCartBottomBar(),
    );
  }
}

/* ================================================= */
/* VIEW CART BOTTOM BAR (🔥 UPDATED)                 */
/* ================================================= */

class _ViewCartBottomBar extends StatelessWidget {
  const _ViewCartBottomBar();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthController.instance.isLoggedIn;

    // Listen to the correct controller
    return ValueListenableBuilder(
      valueListenable: isLoggedIn
          ? CartController.instance
          : LocalCartController.instance,
      builder: (context, cartValue, _) {
        
        // 1. Calculate Totals
        int itemCount = 0;
        double totalPrice = 0;

        if (isLoggedIn && cartValue is Cart) {
          // Server Cart
          itemCount = cartValue.itemCount;
          totalPrice = cartValue.grandTotal;
        } else {
          // Local Cart
          // Safely access items list from controller instance
          final items = LocalCartController.instance.items;
          itemCount = items.fold(0, (sum, item) => sum + item.quantity);
          totalPrice = items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
        }

        // 2. Hide if empty
        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        // 3. Show Green Bar
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: InkWell(
              onTap: () async {
                // ✅ LOGIC: Check Login -> Then Go to Checkout
                await AuthRequiredAction.run(
                  context,
                  // ⭐ FIX: Added 'async' here to solve Future<void> error
                  action: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(), // ✅ Direct to Checkout
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(HomeSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: HomeColors.primaryGreen,
                  borderRadius: BorderRadius.circular(HomeSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Count & Price
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount ITEMS',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Right: Checkout >
                    const Row(
                      children: [
                        Text(
                          'Checkout', // ✅ Updated Text
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}