import 'package:flutter/material.dart';
import 'dart:ui';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static const String kHeroBgImage = 'assets/images/tender_coconut.jpg';
  static const String kSugarcaneImage = 'assets/images/banner.jpg';
  static const String kCoconutImage = 'assets/images/banner2.jpg';
  static const String kFruitImage = 'assets/images/cate-1.jpg';

  static const Color kPrimaryGreen = Color(0xFF2E7D32);
  static const Color kBrandYellow = Color(0xFFFFD600);
  static const Color kDarkText = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. ✨ REPAIRED HEADER (Fixed Overflow)
          _buildSliverAppBar(),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 2. 🌱 HERO CARD (Reduced Height)
                _buildModernHero(),

                const SizedBox(height: 24),

                // 3. 🛡️ VALUE PROPS
                _buildSectionHeader('Our Promise', 'Nature’s integrity preserved'),
                const SizedBox(height: 16),
                _buildValueProps(),

                const SizedBox(height: 32),

                // 4. 🥥 INGREDIENT GRID (Compact Height)
                _buildSectionHeader('Farm to Bottle', 'Handpicked ingredients'),
                const SizedBox(height: 16),
                _buildStaggeredIngredients(),

                const SizedBox(height: 32),

                // 5. 💡 HEALTH JOURNAL (Updated to White/Green Palette)
                _buildSectionHeader('Health Journal', 'Small bites of wisdom'),
                const SizedBox(height: 16),
                _buildJournalCards(),
                
                const SizedBox(height: 40), 
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.white,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
        centerTitle: false,
        title: const Text(
          'Cane & Tender',
          style: TextStyle(
            color: kDarkText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildModernHero() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage(kHeroBgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kBrandYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SEASONAL',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The Art of\nCold-Pressed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueProps() {
    final props = [
      ('No Sugar', Icons.bolt),
      ('100% Organic', Icons.eco),
      ('Eco-Friendly', Icons.recycling),
    ];

    return Row(
      children: props.map((p) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(p.$2, color: kPrimaryGreen, size: 24),
                const SizedBox(height: 8),
                Text(
                  p.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kDarkText),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStaggeredIngredients() {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _ingredientCard('Sugarcane', 'Raw Energy', kSugarcaneImage),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: _ingredientCard('Coconut', 'Hydrate', kCoconutImage)),
                const SizedBox(height: 10),
                Expanded(child: _ingredientCard('Fruits', 'Vitamins', kFruitImage)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientCard(String title, String sub, String img) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCards() {
    final journals = [
      'Natural electrolytes are superior to processed sports drinks for recovery.',
      'Fresh sugarcane juice provides an instant glucose boost for brain health.',
      'Cold-pressed extraction preserves 99% of live nutrients and enzymes.',
    ];

    return Column(
      children: journals.map((text) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: kPrimaryGreen.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_outlined, color: kPrimaryGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: kDarkText, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500, 
                    height: 1.4
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kDarkText, letterSpacing: -0.5),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}