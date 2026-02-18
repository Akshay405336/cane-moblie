import 'package:flutter/material.dart';
import '../models/category.model.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';
import '../theme/home_colors.dart'; // Ensure HomeColors.primaryGreen is defined here

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategoryId; // 🔥 Track which category is selected
  final void Function(Category category)? onTap;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId, // 🔥 Required for filtering logic
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (HomeSpacing.md * 2) - (HomeSpacing.md * 2)) / 3.2;

    return Padding(
      padding: const EdgeInsets.only(top: HomeSpacing.sm),
      child: SizedBox(
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
            // 🔥 Check if this specific tile is the selected one
            final isSelected = category.id == selectedCategoryId;

            return CategoryIconTile(
              key: ValueKey(category.id),
              category: category,
              width: itemWidth,
              isSelected: isSelected, // 🔥 Pass selection state
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
/* CATEGORY ICON TILE (ZEPTO STYLE SELECTION)        */
/* ================================================= */

class CategoryIconTile extends StatelessWidget {
  final Category category;
  final double width;
  final bool isSelected; // 🔥 Selection state
  final VoidCallback? onTap;

  const CategoryIconTile({
    super.key,
    required this.category,
    required this.width,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = _CategoryStyle.iconColorFor(category.id);
    final icon = _CategoryStyle.iconFor(category.id);

    // 🔥 Zepto-style active colors
    final activeBg = HomeColors.primaryGreen.withOpacity(0.12);
    final activeBorder = HomeColors.primaryGreen.withOpacity(0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer( // 🔥 Added animation for selection transition
          duration: const Duration(milliseconds: 250),
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // 🔥 Change background if selected
            color: isSelected ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              // 🔥 Thicker brand border if selected
              color: isSelected ? activeBorder : Colors.grey.withOpacity(0.1),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D1617).withOpacity(isSelected ? 0.12 : 0.08),
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // 🔥 Circle background adapts to selection or image availability
                  color: isSelected 
                      ? Colors.white 
                      : Colors.grey.withOpacity(0.05), // Light background for the image/asset
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _CategoryIcon(
                  imageUrl: category.imageUrl,
                  icon: icon,
                  iconColor: isSelected ? HomeColors.primaryGreen : iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeTextStyles.body.copyWith(
                    fontSize: 13,
                    height: 1.1,
                    // 🔥 Bold and Brand Color if selected
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? HomeColors.primaryGreen : Colors.black87,
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
/* IMAGE / ASSET / ICON SWITCH (UPDATED)             */
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
    // 1. If Network Image is provided
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAsset(),
        ),
      );
    }

    // 2. If no Network Image, use the local '1.png' asset
    return _buildFallbackAsset();
  }

  // Fallback helper to keep code clean
  Widget _buildFallbackAsset() {
    return ClipOval(
      child: Image.asset(
        'assets/images/3.png',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        // If the asset itself fails (typo in path), show the icon style
        errorBuilder: (_, __, ___) => Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
      ),
    );
  }
}

/* ================================================= */
/* CATEGORY STYLE ENGINE (UNCHANGED LOGIC)           */
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