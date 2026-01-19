import 'package:flutter/material.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class DiscountBadge extends StatelessWidget {
  final int percent;

  const DiscountBadge({
    super.key,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HomeSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: HomeColors.pureWhite,
          borderRadius: BorderRadius.circular(
            HomeSpacing.radiusSm,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$percent% OFF',
          style: HomeTextStyles.discount,
        ),
      ),
    );
  }
}
