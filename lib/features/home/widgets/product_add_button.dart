import 'package:flutter/material.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class ProductAddButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProductAddButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          HomeSpacing.radiusSm,
        ),
        child: Container(
          height: 32,
          constraints: const BoxConstraints(
            minWidth: 64, // ✅ prevents squeeze in grid
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: HomeSpacing.sm,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HomeColors.pureWhite,
            borderRadius: BorderRadius.circular(
              HomeSpacing.radiusSm,
            ),
            border: Border.all(
              color: HomeColors.primaryGreen,
              width: 1.2,
            ),
          ),
          child: Text(
            '+ ADD',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HomeTextStyles.addButton,
          ),
        ),
      ),
    );
  }
}
