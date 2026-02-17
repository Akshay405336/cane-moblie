import 'package:flutter/material.dart';
import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        HomeSpacing.md, 
        HomeSpacing.lg, // Added extra top padding for status bar safety
        HomeSpacing.md, 
        HomeSpacing.md
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HomeColors.greenPastry.withOpacity(0.8),
            HomeColors.greenPastry,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: HomeColors.textGrey.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    'DELIVERING TO',
                    style: HomeTextStyles.bodyGrey.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Home, SLN Layout',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: HomeColors.primaryGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: HomeColors.primaryGreen,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          /// Profile Avatar with subtle border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: HomeColors.pureWhite,
              child: Icon(
                Icons.person_outline_rounded,
                color: HomeColors.primaryGreen,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}