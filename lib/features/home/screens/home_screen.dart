import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../models/product.model.dart';

import '../services/category_socket_service.dart';
import '../services/product_socket_service.dart';

import '../sections/home_search.section.dart';
import '../sections/home_categories.section.dart';
import '../sections/home_products.section.dart';
import '../widgets/home_banner_slider.section.dart';

import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';

import 'products.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    /* ================= CATEGORIES ================= */

    // 1️⃣ Subscribe first
    CategorySocketService.subscribe(_onCategories);

    // 2️⃣ Hydrate from cache (instant UI)
    final cachedCategories =
        CategorySocketService.cachedCategories;

    if (cachedCategories.isNotEmpty) {
      _categories = cachedCategories;
      _loadingCategories = false;
    }

    // 3️⃣ Ensure socket connected
    CategorySocketService.connect();

    /* ================= PRODUCTS ================= */

    ProductSocketService.subscribe(_onProducts);

    final cachedProducts =
        ProductSocketService.cachedProducts;

    if (cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _loadingProducts = false;
    }

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
    return Scaffold(
      backgroundColor: HomeColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('home-scroll'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: HomeSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* ================= TOP GREEN ================= */

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  bottom: HomeSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3FBF5),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: const [
                    SizedBox(height: HomeSpacing.sm),
                    HomeSearchSection(),
                    SizedBox(height: HomeSpacing.md),
                    HomeBannerSliderSection(),
                  ],
                ),
              ),

              /* ================= CATEGORIES ================= */

              const SizedBox(height: HomeSpacing.lg),

              HomeCategoriesSection(
                key: const ValueKey('home-categories'),
                loading: _loadingCategories,
                categories: _categories,
              ),

              /* ================= PRODUCTS ================= */

              const SizedBox(height: HomeSpacing.xl),

              HomeProductsSection(
                key: const ValueKey('home-products'),
                loading: _loadingProducts,
                products: _products,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
