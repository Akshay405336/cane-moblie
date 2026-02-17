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
      "title": "Sweet Energy",
      "subtitle": "Freshly Pressed\nSugarcane Juice",
      "image": "assets/images/homebg2.png",
      "accentColor": const Color(0xFFD38345), // Orange for NATURAL
      "tag": "NATURAL",
      "tagBg": Color(0xFFFFEBDD),
    },
    {
      "title": "Pure Hydration",
      "subtitle": "100% Organic\nTender Coconut",
      "image": "assets/images/homebg3.png",
      "accentColor": const Color(0xFF6B8E23), // Olive Green for FRESH
      "tag": "FRESH",
      "tagBg": Color(0xFFF0F4E8),
    },
    {
      "title": "Zesty Refresh",
      "subtitle": "Chilled Mint\n& Lime Zest",
      "image": "assets/images/homebg4.png",
      "accentColor": const Color(0xFF008080), // Teal for ICE COLD
      "tag": "ICE COLD",
      "tagBg": Color(0xFFE0F2F1),
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
          height: 200, // Adjusted height for better proportions
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/home.png"), // Main Background
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Row( // Using Row to separate Text (Left) and Image (Right)
                          children: [
                            // 1. Text Section (Left Side)
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: slide['tagBg'],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        slide['tag'],
                                        style: TextStyle(
                                          color: slide['accentColor'],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      slide['title'],
                                      style: const TextStyle(
                                        color: Color(0xFF2C3E33), // Darker organic green
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      slide['subtitle'],
                                      style: TextStyle(
                                        color: const Color(0xFF2C3E33).withOpacity(0.7),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // 2. Product Image Section (Right Side)
                            Expanded(
                              flex: 4,
                              child: Hero(
                                tag: slide['image'],
                                child: Image.asset(
                                  slide['image'],
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Page Indicators
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: _currentPage == index ? 20 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? const Color(0xFF2C3E33) 
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