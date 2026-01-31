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
        // Slightly increased height to accommodate the fresher look
        height: 130, 
        child: ListView.separated(
          key: const PageStorageKey('category-list'),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.md,
            vertical: 10, // Added vertical padding for shadow breathing room
          ),
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: HomeSpacing.md), // Slightly wider gap
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
/* CATEGORY ICON TILE (ADAPTIVE HEIGHT)              */
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
    // Get dynamic colors
    final iconColor = _CategoryStyle.iconColorFor(category.id);
    final icon = _CategoryStyle.iconFor(category.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), // Softer corners
        child: Container(
          width: 80, // Slightly wider for better breathing room
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.08), // Subtle border
              width: 1,
            ),
            boxShadow: [
              // Modern, diffused shadow
              BoxShadow(
                color: const Color(0xFF1D1617).withOpacity(0.07),
                offset: const Offset(0, 8),
                blurRadius: 15,
                spreadRadius: -3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // Dynamic background color (15% opacity)
                  color: category.imageUrl != null && category.imageUrl!.isNotEmpty
                      ? Colors.grey.withOpacity(0.05)
                      : iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _CategoryIcon(
                  imageUrl: category.imageUrl,
                  icon: icon,
                  iconColor: iconColor,
                ),
              ),
              const SizedBox(height: 10),
              
              // Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTextStyles.body.copyWith(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
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
      return ClipOval( // Changed to Oval for consistency with container
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: 24,
      color: iconColor,
    );
  }
}

/* ================================================= */
/* CATEGORY STYLE ENGINE                             */
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
    final index = seed.hashCode.abs() % _iconColors.length;
    return _iconColors[index];
  }
}