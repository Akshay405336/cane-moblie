import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../services/category_socket_service.dart';
import '../widgets/category_list.widget.dart';
import '../widgets/category_shimmer.widget.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // 🔥 SUBSCRIBE FIRST
    CategorySocketService.subscribe(_onCategories);

    // ✅ USE CACHED DATA IMMEDIATELY
    final cached =
        CategorySocketService.cachedCategories;

    if (cached.isNotEmpty) {
      _categories = cached;
      _loading = false;
    } else {
      CategorySocketService.connect();
    }

    // 🛟 SAFETY TIMEOUT
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (_loading) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    CategorySocketService.unsubscribe(_onCategories);
    super.dispose();
  }

  /* ================= SOCKET HANDLER ================= */

  void _onCategories(List<Category> categories) {
    if (!mounted) return;

    setState(() {
      _categories = categories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.pureWhite,
      appBar: AppBar(
        backgroundColor: HomeColors.greenPastry,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: HomeTextStyles.sectionTitle,
        ),
        iconTheme: const IconThemeData(
          color: HomeColors.primaryGreen,
        ),
      ),
      body: _loading
          ? const CategoryShimmer()
          : _categories.isEmpty
              ? _EmptyState()
              : Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: HomeSpacing.md),

                    /// Horizontal categories (Zepto style)
                    CategoryListWidget(
                      categories: _categories,
                    ),

                    const SizedBox(
                        height: HomeSpacing.lg),

                    /// Vertical list
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HomeSpacing.md,
                        ),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                                height: HomeSpacing.sm),
                        itemBuilder:
                            (context, index) {
                          final category =
                              _categories[index];

                          return _CategoryRow(
                            name: category.name,
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

/* ================================================= */
/* CATEGORY ROW (VERTICAL LIST)                       */
/* ================================================= */

class _CategoryRow extends StatelessWidget {
  final String name;

  const _CategoryRow({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: HomeColors.lightGrey,
        borderRadius:
            BorderRadius.circular(HomeSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: HomeColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: HomeColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: HomeSpacing.md),
          Expanded(
            child: Text(
              name,
              style: HomeTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: HomeColors.textLightGrey,
          ),
        ],
      ),
    );
  }
}

/* ================================================= */
/* EMPTY STATE                                       */
/* ================================================= */

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No categories available',
        style: TextStyle(
          color: HomeColors.textGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}
