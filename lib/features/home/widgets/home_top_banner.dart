import 'dart:async';
import 'package:flutter/material.dart';

class HomeTopBanner extends StatefulWidget {
  const HomeTopBanner({super.key});

  @override
  State<HomeTopBanner> createState() => _HomeTopBannerState();
}

class _HomeTopBannerState extends State<HomeTopBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Data for the 3 slides using your PNGs
  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Pure Hydration",
      "subtitle": "100% Organic Tender Coconut",
      "image": "assets/images/homebg1.png", 
      "colors": [const Color(0xFF00b09b), const Color(0xFF96c93d)],
      "tag": "FRESH"
    },
    {
      "title": "Sweet Energy",
      "subtitle": "Freshly Pressed Sugarcane",
      "image": "assets/images/homebg2.png",
      "colors": [const Color(0xFFf2994a), const Color(0xFFf2c94c)],
      "tag": "NATURAL"
    },
    {
      "title": "Zesty Refresh",
      "subtitle": "Chilled Mint & Lime Juice",
      "image": "assets/images/homebg4.png",
      "colors": [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      "tag": "ICE COLD"
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-slide every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: slide['colors'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (slide['colors'][0] as Color).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  slide['tag'],
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 1
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                slide['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                slide['subtitle'],
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Transform.scale(
                            scale: 1.2,
                            child: Image.asset(slide['image'], fit: BoxFit.contain),
                          ),
                        ),
                      ],
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