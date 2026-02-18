import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../widgets/category_list.widget.dart';
import '../widgets/category_shimmer.widget.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';
import '../theme/home_colors.dart';

class HomeCategoriesSection extends StatelessWidget {
  final bool loading;
  final List<Category> categories;
  // 🔥 NEW: Selection state and callback
  final String selectedCategoryId;
  final Function(Category) onCategoryTap;

  const HomeCategoriesSection({
    super.key,
    required this.loading,
    required this.categories,
    required this.selectedCategoryId, // 🔥 Required for filtering
    required this.onCategoryTap,      // 🔥 Required for updates
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home-categories-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(),
        const SizedBox(height: HomeSpacing.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const CategoryShimmer(
                  key: ValueKey('category-shimmer'),
                )
              : CategoryListWidget(
                  key: const ValueKey('category-list'),
                  categories: categories,
                  // 🔥 Pass the current selection to the list
                  selectedCategoryId: selectedCategoryId,
                  // 🔥 Handle the tap to update selection
                  onTap: onCategoryTap,
                ),
        ),
      ],
    );
  }
}

/* ================================================= */
/* HEADER                                            */
/* ================================================= */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: HomeSpacing.md),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: HomeColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Categories',
            style: HomeTextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}