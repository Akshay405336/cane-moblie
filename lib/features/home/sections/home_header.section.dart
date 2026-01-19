import 'package:flutter/material.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HomeSpacing.md),
      decoration: const BoxDecoration(
        color: HomeColors.greenPastry,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Delivering to',
                style: HomeTextStyles.bodyGrey,
              ),
              SizedBox(height: 4),
              Text(
                'Home, SLN Layout ▼',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeColors.primaryGreen,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: HomeColors.pureWhite,
            child: Icon(
              Icons.person,
              color: HomeColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
