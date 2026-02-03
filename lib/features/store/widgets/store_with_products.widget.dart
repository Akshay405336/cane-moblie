import 'package:flutter/material.dart';
import '../../store/models/outlet.model.dart';
import '../../store/models/product.model.dart';
import '../../store/services/product_api.dart'; // Ensure path is correct
import '../../store/widgets/outlet_card.widget.dart';
import 'mini_product_card.widget.dart';

class StoreWithProductsWidget extends StatefulWidget {
  final Outlet outlet;

  const StoreWithProductsWidget({
    super.key,
    required this.outlet,
  });

  @override
  State<StoreWithProductsWidget> createState() => _StoreWithProductsWidgetState();
}

class _StoreWithProductsWidgetState extends State<StoreWithProductsWidget> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreProducts();
  }

  Future<void> _fetchStoreProducts() async {
    try {
      // Fetch products for this specific outlet
      final allProducts = await ProductApi.getByOutlet(widget.outlet.id);
      
      if (mounted) {
        setState(() {
          // Take only top 5 products for the home screen preview
          _products = allProducts.take(5).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint("Error fetching products for outlet ${widget.outlet.name}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ================= STORE CARD ================= */
        // We use the existing OutletCard you provided
        OutletCard(outlet: widget.outlet),

        /* ================= PRODUCTS LIST ================= */
        // Only show if we have products
        if (!_loading && _products.isNotEmpty) ...[
          const SizedBox(height: 12),
          
          SizedBox(
            height: 170, // Fixed height for the horizontal scroller
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Add padding to align with the card above
              padding: const EdgeInsets.only(left: 4), 
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return MiniProductCard(product: _products[index]);
              },
            ),
          ),
          
          const SizedBox(height: 8), // Extra spacing before next store
        ] 
        // Optional: Show a small loader while fetching
        else if (_loading)
           const Padding(
             padding: EdgeInsets.only(top: 12, left: 16),
             child: SizedBox(
               height: 20, width: 20, 
               child: CircularProgressIndicator(strokeWidth: 2)
             ),
           ),
      ],
    );
  }
}