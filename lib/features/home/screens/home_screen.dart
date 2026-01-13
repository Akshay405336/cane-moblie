import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../services/category_api.dart';
import '../widgets/category_list.widget.dart';
import 'categories.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await CategoryApi.getAll();
    if (!mounted) return;
    setState(() {
      _categories = data;
      _loadingCategories = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌱 HERO BANNER
          _heroBanner(),

          const SizedBox(height: 20),

          // 🍹 CATEGORIES
          _categoryHeader(context),
          _categorySection(),
        ],
      ),
    );
  }

  /* -------------------------------------------------- */
  /* CATEGORY SECTION                                  */
  /* -------------------------------------------------- */

  Widget _categoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Fresh Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
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
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFF43A047),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categorySection() {
    if (_loadingCategories) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Text(
          'No categories available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return CategoryListWidget(
      categories: _categories,
    );
  }

  /* -------------------------------------------------- */
  /* HERO BANNER                                       */
  /* -------------------------------------------------- */

  Widget _heroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF66BB6A),
            Color(0xFF43A047),
          ],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh. Natural.\nCold Pressed.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pure sugarcane & fruit juices\nserved fresh everyday 🌱',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.local_drink,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
