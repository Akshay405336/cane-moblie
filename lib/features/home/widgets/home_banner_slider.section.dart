import 'dart:async';
import 'package:flutter/material.dart';

class HomeBannerSliderSection extends StatefulWidget {
  const HomeBannerSliderSection({Key? key}) : super(key: key);

  @override
  State<HomeBannerSliderSection> createState() =>
      _HomeBannerSliderSectionState();
}

class _HomeBannerSliderSectionState
    extends State<HomeBannerSliderSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // 🔁 Replace these paths later
  final List<String> banners = [
    'assets/images/1.png',
    'assets/images/2.png',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 4), // ⏱️ 3–5 sec smooth slide
      (timer) {
        if (_pageController.hasClients) {
          _currentPage =
              (_currentPage + 1) % banners.length;

          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 4,    // ⬆️ reduced top space
      bottom: 6, // ⬇️ reduced bottom space
    ),
    child: SizedBox(
      height: 175, // ⬅️ reduced from 160
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, // ⬅️ slightly tighter sides
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                banners[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    ),
  );
}
    }
