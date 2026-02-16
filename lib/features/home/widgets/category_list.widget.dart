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

    // Calculate dynamic width for 3 items per row
    // ScreenWidth - (Horizontal Padding * 2) - (Separators * 2) / 3
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (HomeSpacing.md * 2) - (HomeSpacing.md * 2)) / 3.2;

    return Padding(
      padding: const EdgeInsets.only(top: HomeSpacing.sm),
      child: SizedBox(
        // Increased height for larger boxes
        height: 150, 
        child: ListView.separated(
          key: const PageStorageKey('category-list'),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.md,
            vertical: 12, 
          ),
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: HomeSpacing.md),
          itemBuilder: (context, index) {
            final category = categories[index];

            return CategoryIconTile(
              key: ValueKey(category.id),
              category: category,
              width: itemWidth, // Pass the calculated width
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
  final double width;
  final VoidCallback? onTap;

  const CategoryIconTile({
    super.key,
    required this.category,
    required this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = _CategoryStyle.iconColorFor(category.id);
    final icon = _CategoryStyle.iconFor(category.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: width, // Dynamic width for 3 per row
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D1617).withOpacity(0.08),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Larger Icon Container
              Container(
                width: 56, // Increased from 48
                height: 56, // Increased from 48
                decoration: BoxDecoration(
                  color: category.imageUrl != null && category.imageUrl!.isNotEmpty
                      ? Colors.grey.withOpacity(0.05)
                      : iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _CategoryIcon(
                  imageUrl: category.imageUrl,
                  icon: icon,
                  iconColor: iconColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Text with slightly larger font
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTextStyles.body.copyWith(
                    fontSize: 13, // Increased from 12
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.1,
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
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            icon,
            size: 28, // Increased icon size
            color: iconColor,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: 28, // Increased icon size
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