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

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Pure Hydration",
      "subtitle": "100% Organic\nTender Coconut",
      "image": "assets/images/homebg3.png",
      "accentColor": const Color(0xFF2E7D32),
      "tag": "FRESH"
    },
    {
      "title": "Sweet Energy",
      "subtitle": "Freshly Pressed\nSugarcane Juice",
      "image": "assets/images/homebg2.png",
      "accentColor": const Color(0xFFF2994A),
      "tag": "NATURAL"
    },
    {
      "title": "Zesty Refresh",
      "subtitle": "Chilled Mint\n& Lime Zest",
      "image": "assets/images/homebg4.png",
      "accentColor": const Color(0xFF11998E),
      "tag": "ICE COLD"
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.decelerate,
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
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }

                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeInOut.transform(value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, // Pure white background
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: (slide['accentColor'] as Color).withOpacity(0.12),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Row(
                                  children: [
                                    // Text Content Section
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (slide['accentColor'] as Color).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              slide['tag'],
                                              style: TextStyle(
                                                color: slide['accentColor'],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            slide['title'],
                                            style: const TextStyle(
                                              color: Color(0xFF1A1A1A),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              height: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            slide['subtitle'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Image Section - Increased flex and image height
                                    Expanded(
                                      flex: 6, // Increased from 4
                                      child: Transform.translate(
                                        offset: const Offset(15, 0), // Adjusted for larger size
                                        child: Transform.rotate(
                                          angle: -0.05,
                                          child: Hero(
                                            tag: slide['image'],
                                            child: Image.asset(
                                              slide['image'],
                                              fit: BoxFit.contain,
                                              height: 240, // Increased from 160
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Modernized Page Indicators
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? _slides[index]['accentColor'] 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}