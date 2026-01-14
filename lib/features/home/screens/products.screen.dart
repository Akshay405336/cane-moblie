import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../services/product_socket_service.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // 🔥 SUBSCRIBE FIRST
    ProductSocketService.subscribe(_onProducts);

    // ✅ USE CACHE IF AVAILABLE
    final cachedProducts =
        ProductSocketService.cachedProducts;

    if (cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _loading = false;
    } else {
      ProductSocketService.connect();
    }
  }

  @override
  void dispose() {
    ProductSocketService.unsubscribe(_onProducts);
    super.dispose();
  }

  /* -------------------------------------------------- */
  /* SOCKET HANDLER                                     */
  /* -------------------------------------------------- */

  void _onProducts(List<Product> products) {
    if (!mounted) return;

    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
      ),
      body: _loading
          ? const ProductShimmerWidget()
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(bottom: 24),
                  child: ProductGridWidget(
                    products: _products,
                  ),
                ),
    );
  }
}
