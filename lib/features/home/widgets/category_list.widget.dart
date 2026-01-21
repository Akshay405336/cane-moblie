import 'package:flutter/material.dart';
import '../models/category.model.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category category)? onTap;

  const CategoryListWidget({
    super.key,
    required this.categories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: HomeSpacing.sm),
      child: SizedBox(
        height: 104, // space for shadow
        child: ListView.separated(
          key: const PageStorageKey('category-list'),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.md,
            vertical: 6,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: HomeSpacing.sm),
          itemBuilder: (context, index) {
            final category = categories[index];

            return CategoryIconTile(
              key: ValueKey(category.id), // 🔒 stable on realtime update
              name: category.name,
              icon: _CategoryStyle.iconFor(category.id),
              iconColor: _CategoryStyle.iconColorFor(category.id),
              onTap: onTap == null
                  ? null
                  : () => onTap!(category),
            );
          },
        ),
      ),
    );
  }
}

/* ================================================= */
/* CATEGORY ICON TILE                                */
/* ================================================= */

class CategoryIconTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const CategoryIconTile({
    super.key,
    required this.name,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(3, 7),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: iconColor,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HomeTextStyles.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* CATEGORY STYLE ENGINE                              */
/* ================================================= */

class _CategoryStyle {
  static const List<Color> _iconColors = [
    Color(0xFF03B602),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFFFF5722),
  ];

  static const List<IconData> _icons = [
    Icons.local_florist,
    Icons.eco,
    Icons.apple,
    Icons.restaurant,
    Icons.local_grocery_store,
    Icons.spa,
    Icons.grass,
  ];

  static IconData iconFor(String seed) {
    final index = seed.hashCode.abs() % _icons.length;
    return _icons[index];
  }

  static Color iconColorFor(String seed) {
    final index =
        seed.hashCode.abs() % _iconColors.length;
    return _iconColors[index];
  }
}
