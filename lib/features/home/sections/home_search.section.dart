import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeSearchSection extends StatefulWidget {
  const HomeSearchSection({super.key});

  @override
  State<HomeSearchSection> createState() =>
      _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection> {
  final List<String> _hints = const [
    'Search for "Sugarcane"',
    'Search for "Coconut"',
    'Search for "Milk"',
    'Search for "Jaggery"',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % _hints.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: HomeSpacing.md,
      vertical: HomeSpacing.sm,
    ),
    child: Row(
      children: [
        /// 🔍 SEARCH BAR
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.md,
            ),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(HomeSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: HomeColors.textGrey,
                ),
                const SizedBox(width: HomeSpacing.sm),

                /// Animated hint text
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(fade);

                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(
                          position: slide,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _hints[_currentIndex],
                      key: ValueKey(_hints[_currentIndex]),
                      style: HomeTextStyles.bodyGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: HomeSpacing.sm),

        /// 🖼️ CANE POSTER
        ClipRRect(
          borderRadius:
              BorderRadius.circular(HomeSpacing.radiusLg),
          child: Image.asset(
            'assets/images/cane-poster.png',
            width: 72,          // 👈 adjust as needed
            height: 48,
            fit: BoxFit.fill,
          ),
        ),
      ],
    ),
  );
}
}