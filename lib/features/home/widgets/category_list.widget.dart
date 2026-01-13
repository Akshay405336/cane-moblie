import 'package:flutter/material.dart';

import '../models/category.model.dart';

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;

  const CategoryListWidget({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = categories[index];

          final color =
              _CategoryStyle.colorFor(category.id);
          final icon =
              _CategoryStyle.iconFor(category.id);

          return _CategoryCard(
            name: category.name,
            color: color,
            icon: icon,
          );
        },
      ),
    );
  }
}

/* ================================================= */
/* CATEGORY CARD                                     */
/* ================================================= */

class _CategoryCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;

  const _CategoryCard({
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.black87,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================================================= */
/* CATEGORY STYLE ENGINE                              */
/* ================================================= */

class _CategoryStyle {
  /// Soft pastel / creamy colors
  static const List<Color> _colors = [
    Color(0xFFFFF3E0), // cream peach
    Color(0xFFE8F5E9), // mint cream
    Color(0xFFE3F2FD), // light sky
    Color(0xFFF3E5F5), // lavender cream
    Color(0xFFFFEBEE), // rose cream
    Color(0xFFE0F2F1), // aqua cream
    Color(0xFFFFFDE7), // butter cream
  ];

  /// Icons that fit groceries / categories
  static const List<IconData> _icons = [
    Icons.local_florist,
    Icons.eco,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.local_grocery_store,
    Icons.grass,
    Icons.apple,
    Icons.spa,
  ];

  /// Always returns same color for same category
  static Color colorFor(String seed) {
    final index = seed.hashCode.abs() % _colors.length;
    return _colors[index];
  }

  /// Always returns same icon for same category
  static IconData iconFor(String seed) {
    final index = seed.hashCode.abs() % _icons.length;
    return _icons[index];
  }
}
