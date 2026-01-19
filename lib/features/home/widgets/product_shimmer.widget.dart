import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';

class ProductShimmerWidget extends StatelessWidget {
  const ProductShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
      ),
      itemCount: 6,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: HomeSpacing.md,
        crossAxisSpacing: HomeSpacing.md,
        childAspectRatio: 0.64, // matches product grid
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: HomeColors.lightGrey,
          highlightColor: HomeColors.creamyWhite,
          child: Container(
            decoration: BoxDecoration(
              color: HomeColors.pureWhite,
              borderRadius: BorderRadius.circular(
                HomeSpacing.radiusLg,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* IMAGE PLACEHOLDER */
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: HomeColors.lightGrey,
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(
                          HomeSpacing.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ),

                /* TEXT + PRICE PLACEHOLDER */
                Padding(
                  padding: const EdgeInsets.all(
                    HomeSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: HomeColors.lightGrey,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 12,
                            width: 60,
                            color: HomeColors.lightGrey,
                          ),
                          Container(
                            height: 24,
                            width: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    HomeColors.lightGrey,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                HomeSpacing.radiusSm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
