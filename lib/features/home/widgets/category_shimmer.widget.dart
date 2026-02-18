import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Match the dynamic width calculation from your CategoryListWidget
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (HomeSpacing.md * 2) - (HomeSpacing.md * 2)) / 3.2;

    return SizedBox(
      height: 150, // 🔥 Match the actual CategoryListWidget height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.md,
          vertical: 12, // 🔥 Match the vertical padding
        ),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(width: HomeSpacing.md), // 🔥 Match the md spacing
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: HomeColors.lightGrey,
            highlightColor: HomeColors.pureWhite.withOpacity(0.5),
            child: Container(
              width: itemWidth, // 🔥 Match the dynamic width
              decoration: BoxDecoration(
                color: HomeColors.lightGrey,
                borderRadius: BorderRadius.circular(24), // 🔥 Match the tile radius
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circle Icon Shimmer
                  Container(
                    height: 56, // 🔥 Match the increased 56px size
                    width: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Text Label Shimmer
                  Container(
                    height: 12,
                    width: itemWidth * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}