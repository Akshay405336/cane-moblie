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
        // 🔥 Only list has fixed height — tiles are adaptive
        height: 120,
        child: ListView.separated(
          key: const PageStorageKey('category-list'),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.md,
            vertical: 8,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: HomeSpacing.sm),
          itemBuilder: (context, index) {
            final category = categories[index];

            return CategoryIconTile(
              key: ValueKey(category.id),
              category: category,
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
/* CATEGORY ICON TILE (ADAPTIVE HEIGHT)               */
/* ================================================= */

class CategoryIconTile extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryIconTile({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        _CategoryStyle.iconFor(category.id);
    final iconColor =
        _CategoryStyle.iconColorFor(category.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
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
          mainAxisSize: MainAxisSize.min, // 🔥 adaptive
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CategoryIcon(
              imageUrl: category.imageUrl,
              icon: icon,
              iconColor: iconColor,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HomeTextStyles.body.copyWith(
                fontSize: 12,
                height: 1.1,
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
/* IMAGE / ICON SWITCH                               */
/* ================================================= */

class _CategoryIcon extends StatelessWidget {
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;

  const _CategoryIcon({
    required this.imageUrl,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            icon,
            size: 26,
            color: iconColor,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: 26,
      color: iconColor,
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
