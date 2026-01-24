import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../models/outlet.model.dart';

import '../services/product_socket_service.dart';

import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';

class OutletProductsScreen extends StatefulWidget {
  final Outlet outlet;

  const OutletProductsScreen({
    super.key,
    required this.outlet,
  });

  @override
  State<OutletProductsScreen> createState() =>
      _OutletProductsScreenState();
}

class _OutletProductsScreenState
    extends State<OutletProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;

  /* ================================================= */
  /* INIT ⭐ SIMPLIFIED                                 */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    debugPrint(
        '🛒 Products screen opened → outlet=${widget.outlet.id}');

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

    debugPrint(
        '🛒 Products received → count=${products.length}');

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
      appBar: AppBar(
        title: Text(widget.outlet.name),
      ),
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
    );
  }
}
