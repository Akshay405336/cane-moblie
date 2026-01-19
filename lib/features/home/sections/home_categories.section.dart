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

  const HomeCategoriesSection({
    super.key,
    required this.loading,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: HomeSpacing.md), // ✅ little more space
        loading
            ? const CategoryShimmer()
            : CategoryListWidget(categories: categories),
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSpacing.md),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: HomeColors.primaryGreen, // ✅ dark green accent
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Categories',
            style: HomeTextStyles.sectionTitle.copyWith(
              fontSize: 20, // ✅ bigger text
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
