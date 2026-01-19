import 'package:flutter/material.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeOfferStripSection extends StatelessWidget {
  final String title;

  const HomeOfferStripSection({
    super.key,
    required this.title, // e.g. "Fresh at ₹60"
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(HomeSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
        vertical: HomeSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: HomeColors.greenGradient,
        borderRadius: BorderRadius.circular(HomeSpacing.radiusLg),
      ),
      child: Text(
        title,
        style: HomeTextStyles.offerTitle.copyWith(color: Colors.white),
      ),
    );
  }
}
