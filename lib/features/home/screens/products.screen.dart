import 'package:flutter/material.dart';

import '../models/product.model.dart';
import '../services/product_socket_service.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

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

    /// Subscribe first
    ProductSocketService.subscribe(_onProducts);

    /// Use cache if available
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

  /* ================= SOCKET HANDLER ================= */

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
      backgroundColor: HomeColors.pureWhite,

      /* ================= APP BAR ================= */

      appBar: AppBar(
        backgroundColor: HomeColors.greenPastry,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: HomeTextStyles.sectionTitle,
        ),
        iconTheme: const IconThemeData(
          color: HomeColors.primaryGreen,
        ),
      ),

      /* ================= BODY ================= */

      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(HomeSpacing.md),
              child: ProductShimmerWidget(),
            )
          : _products.isEmpty
              ? const _EmptyState()
              : Padding(
                  padding: const EdgeInsets.only(
                    bottom: HomeSpacing.lg,
                  ),
                  child: ProductGridWidget(
                    products: _products,
                  ),
                ),
    );
  }
}

/* ================================================= */
/* EMPTY STATE                                       */
/* ================================================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No products available',
        style: TextStyle(
          color: HomeColors.textGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}
