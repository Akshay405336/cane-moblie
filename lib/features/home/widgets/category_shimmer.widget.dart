import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.md,
        ),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(width: HomeSpacing.sm),
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: HomeColors.lightGrey,
            highlightColor: HomeColors.creamyWhite,
            child: Container(
              width: 88,
              decoration: BoxDecoration(
                color: HomeColors.lightGrey,
                borderRadius: BorderRadius.circular(
                  HomeSpacing.radiusLg,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: HomeColors.pureWhite,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 50,
                    color: HomeColors.pureWhite,
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
