import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../models/product.model.dart';

import '../services/category_socket_service.dart';
import '../services/product_socket_service.dart';

import '../widgets/category_list.widget.dart';
import '../widgets/category_shimmer.widget.dart';

import '../widgets/product_grid_widget.dart';
import '../widgets/product_shimmer.widget.dart';

import 'categories.screen.dart';
import 'products.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /* ================= CATEGORIES ================= */

  List<Category> _categories = [];
  bool _loadingCategories = true;

  /* ================= PRODUCTS ================= */

  List<Product> _products = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();

    /* ---------- CATEGORIES ---------- */

    final cachedCategories =
        CategorySocketService.cachedCategories;

    if (cachedCategories.isNotEmpty) {
      _categories = cachedCategories;
      _loadingCategories = false;
    }

    CategorySocketService.subscribe(_onCategories);
    CategorySocketService.connect();

    /* ---------- PRODUCTS ---------- */

    final cachedProducts =
        ProductSocketService.cachedProducts;

    if (cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _loadingProducts = false;
    }

    ProductSocketService.subscribe(_onProducts);
    ProductSocketService.connect();
  }

  @override
  void dispose() {
    CategorySocketService.unsubscribe(_onCategories);
    ProductSocketService.unsubscribe(_onProducts);
    super.dispose();
  }

  /* ================= SOCKET HANDLERS ================= */

  void _onCategories(List<Category> categories) {
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _loadingCategories = false;
    });
  }

  void _onProducts(List<Product> products) {
    if (!mounted) return;
    setState(() {
      _products = products;
      _loadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /* ================= CATEGORIES ================= */

            _categoryHeader(context),
            _categorySection(),

            const SizedBox(height: 24),

            /* ================= PRODUCTS ================= */

            _productHeader(context),
            _productSection(),
          ],
        ),
      ),
    );
  }

  /* ================= CATEGORY UI ================= */

  Widget _categoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CategoriesScreen(),
                ),
              );
            },
            child: const Text('View all'),
          ),
        ],
      ),
    );
  }

  Widget _categorySection() {
    if (_loadingCategories) {
      return const CategoryShimmer();
    }

    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No categories available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return CategoryListWidget(categories: _categories);
  }

  /* ================= PRODUCT UI ================= */

  Widget _productHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Fresh Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProductsScreen(),
                ),
              );
            },
            child: const Text('View all'),
          ),
        ],
      ),
    );
  }

  Widget _productSection() {
    if (_loadingProducts) {
      return const ProductShimmerWidget();
    }

    if (_products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No products available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ProductGridWidget(products: _products);
  }
}
