import 'package:flutter/material.dart';
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';

// MODELS
import '../models/product.model.dart';
import '../models/outlet.model.dart';
import '../../cart/models/cart.model.dart';
import '../../home/models/category.model.dart'; // Ensure this is imported

// CONTROLLERS
import '../../auth/state/auth_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';

// SCREENS
import '../../checkout/screens/checkout_screen.dart'; 

// SERVICES
import '../services/product_api.dart'; 

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
  List<Product> _allProducts = []; 
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  
  bool _loading = true;

  // 🔥 FILTER STATES
  String _selectedCategoryId = 'all';
  bool _showTrendingOnly = false;
  String _priceSort = 'none'; // 'none', 'low', 'high'

  @override
  void initState() {
    super.initState();
    _fetchProducts(); 
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final products = await ProductApi.getByOutlet(widget.outlet.id);
      
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _applyAllFilters();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  // 🔥 FIXED UNIQUE CATEGORY LOGIC
  List<Category> _getUniqueCategories() {
    // We use a Map where the Key is the ID to force uniqueness
    final Map<String, Category> categoryMap = {};
    for (var product in _allProducts) {
      if (product.category.id.isNotEmpty) {
        categoryMap[product.category.id] = product.category;
      }
    }
    return categoryMap.values.toList();
  }

  void _applyAllFilters() {
    setState(() {
      List<Product> results = List.from(_allProducts);

      // 1. Search Query
      if (_searchController.text.isNotEmpty) {
        results = results.where((p) => 
          p.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      }

      // 2. Category
      if (_selectedCategoryId != 'all') {
        results = results.where((p) => p.category.id == _selectedCategoryId).toList();
      }

      // 3. Trending
      if (_showTrendingOnly) {
        results = results.where((p) => p.isTrending).toList();
      }

      // 4. Price Sorting
      if (_priceSort == 'low') {
        results.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
      } else if (_priceSort == 'high') {
        results.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
      }

      _filteredProducts = results;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = 'all';
      _showTrendingOnly = false;
      _priceSort = 'none';
      _searchController.clear();
      _applyAllFilters();
    });
  }

  void _onShare() {
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
    final uniqueCategories = _getUniqueCategories();
    final bool hasActiveFilters = _selectedCategoryId != 'all' || _showTrendingOnly || _priceSort != 'none' || _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), 
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
                  title: Text(widget.outlet.name, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                actions: [
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text("Clear", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: _onShare),
                ],
              ),

              SliverToBoxAdapter(child: _OutletInfoCard(outlet: widget.outlet)),

              // 🔥 SEARCH & CATEGORY FILTERS
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _FunctionalSearchBar(
                          controller: _searchController,
                          onChanged: (_) => _applyAllFilters(),
                        ),
                      ),
                      
                      if (_allProducts.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              _buildCategoryChip("All Items", 'all'),
                              ...uniqueCategories.map((cat) => _buildCategoryChip(cat.name, cat.id)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 🔥 ADVANCED FILTERS
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: "Trending", 
                        icon: Icons.whatshot, 
                        isActive: _showTrendingOnly,
                        onTap: () {
                          setState(() => _showTrendingOnly = !_showTrendingOnly);
                          _applyAllFilters();
                        }
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: "Low Price", 
                        icon: Icons.arrow_downward, 
                        isActive: _priceSort == 'low',
                        onTap: () {
                          setState(() => _priceSort = (_priceSort == 'low' ? 'none' : 'low'));
                          _applyAllFilters();
                        }
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: "High Price", 
                        icon: Icons.arrow_upward, 
                        isActive: _priceSort == 'high',
                        onTap: () {
                          setState(() => _priceSort = (_priceSort == 'high' ? 'none' : 'high'));
                          _applyAllFilters();
                        }
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    !hasActiveFilters
                        ? "Items in Store" 
                        : "Filtered Results (${_filteredProducts.length})",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                ),
              ),

              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(16), child: ProductShimmerWidget()),
                ),

              if (!_loading && _filteredProducts.isEmpty)
                const SliverToBoxAdapter(child: _EmptyStateWidget()),

              if (!_loading && _filteredProducts.isNotEmpty)
                ProductGridWidget(
                  products: _filteredProducts,
                  outletId: widget.outlet.id,
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),

          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: _ViewCartBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id) {
    bool isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategoryId = id);
        _applyAllFilters();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? HomeColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? HomeColors.primaryGreen : Colors.grey[300]!),
          boxShadow: isSelected ? [BoxShadow(color: HomeColors.primaryGreen.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? HomeColors.primaryGreen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? HomeColors.primaryGreen : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? HomeColors.primaryGreen : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: isActive ? HomeColors.primaryGreen : Colors.grey[700], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* REMAINING HELPER WIDGETS (STILL INCLUDED)         */
/* ================================================= */

class _FunctionalSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  const _FunctionalSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search items in this outlet...",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
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

class _OutletInfoCard extends StatelessWidget {
  final Outlet outlet;
  const _OutletInfoCard({required this.outlet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text("25-30 mins", style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text("${outlet.branch}", style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.star, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          const Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No items found matching filters", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
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
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: HomeColors.primaryGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: HomeColors.primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
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
                    Text('$itemCount ITEMS', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('₹${totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                const Row(
                  children: [
                    Text('View Cart', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    SizedBox(width: 8),
                    Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
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