import 'package:flutter/material.dart';
// ⭐ IMPORT SHARE PLUS (Run: flutter pub add share_plus)
// import 'package:share_plus/share_plus.dart'; 

// THEME & UTILS
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';

// MODELS
import '../models/product.model.dart';
import '../models/outlet.model.dart';
import '../../cart/models/cart.model.dart'; 

// CONTROLLERS
import '../../auth/state/auth_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';

// SCREENS
import '../../checkout/screens/checkout_screen.dart'; 

// SERVICES
import '../services/product_api.dart'; // ⭐ USING API SERVICE

// UTILS
import '../../../utils/auth_required_action.dart'; 

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
  // ⭐ 1. Data State
  List<Product> _allProducts = []; 
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 Products screen opened → outlet=${widget.outlet.id}');
    _fetchProducts(); // ⭐ Fetch via API
  }

  // ⭐ 2. Fetch Logic (Standard API Pattern)
  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final products = await ProductApi.getByOutlet(widget.outlet.id);
      
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        // Apply existing search if any
        if (_searchController.text.isNotEmpty) {
          _runSearch(_searchController.text);
        } else {
          _filteredProducts = products;
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  // ⭐ 3. Search Logic
  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // ⭐ 4. Share Logic
  void _onShare() {
    final text = "Check out ${widget.outlet.name} on our app! Get fresh milk and groceries delivered instantly.";
    // Share.share(text); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sharing Store Link...")),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), 
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- APP BAR ---
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                  title: Text(
                    widget.outlet.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: _onShare, 
                  ),
                ],
              ),

              // --- INFO CARD ---
              SliverToBoxAdapter(
                child: _OutletInfoCard(outlet: widget.outlet),
              ),

              // --- SEARCH BAR ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _FunctionalSearchBar(
                    controller: _searchController,
                    onChanged: _runSearch,
                  ),
                ),
              ),

              // --- SECTION TITLE ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    _searchController.text.isEmpty 
                        ? "Recommended for you" 
                        : "Search Results (${_filteredProducts.length})",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),

              // --- LOADING STATE ---
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ProductShimmerWidget(),
                  ),
                ),

              // --- EMPTY STATE ---
              if (!_loading && _filteredProducts.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyStateWidget(),
                ),

              // --- PRODUCT GRID (The Professional Sliver) ---
              // ⭐ This must be a direct child of 'slivers', NOT inside SliverToBoxAdapter
              if (!_loading && _filteredProducts.isNotEmpty)
                ProductGridWidget(
                  products: _filteredProducts,
                  outletId: widget.outlet.id,
                ),

              // --- BOTTOM PADDING ---
              // Ensures the last items aren't hidden behind the floating cart bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),

          // --- BOTTOM CART ---
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: _ViewCartBottomBar(),
          ),
        ],
      ),
    );
  }
}

/* ================================================= */
/* FUNCTIONAL SEARCH BAR                             */
/* ================================================= */

class _FunctionalSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _FunctionalSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search, 
        decoration: InputDecoration(
          hintText: "Search for items...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

/* ================================================= */
/* HELPER WIDGETS                                    */
/* ================================================= */

class _OutletInfoCard extends StatelessWidget {
  final Outlet outlet;
  const _OutletInfoCard({required this.outlet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text("•  30-40 mins", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 12),
          Text("•  2 km away", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No items found", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

class _ViewCartBottomBar extends StatelessWidget {
  const _ViewCartBottomBar();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthController.instance.isLoggedIn;
    return ValueListenableBuilder(
      valueListenable: isLoggedIn ? CartController.instance : LocalCartController.instance,
      builder: (context, cartValue, _) {
        int itemCount = 0;
        double totalPrice = 0;

        if (isLoggedIn && cartValue is Cart) {
          itemCount = cartValue.itemCount;
          totalPrice = cartValue.grandTotal;
        } else {
          final items = LocalCartController.instance.items;
          itemCount = items.fold(0, (sum, item) => sum + item.quantity);
          totalPrice = items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
        }

        if (itemCount == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: HomeColors.primaryGreen,
            borderRadius: BorderRadius.circular(HomeSpacing.radiusMd),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: InkWell(
            onTap: () async {
              await AuthRequiredAction.run(context, action: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$itemCount ITEMS', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('₹${totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Row(
                  children: [
                    Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}