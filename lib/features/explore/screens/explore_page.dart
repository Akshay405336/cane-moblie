import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  // ---------------------------------------------------------------------------
  // 🖼️ IMAGE ASSETS
  // These paths match the folder 'assets/images/' defined in your pubspec.yaml
  // ---------------------------------------------------------------------------
  static const String kHeroBgImage = 'assets/images/tender_coconut.jpg';
  static const String kSugarcaneImage = 'assets/images/banner.jpg';  // Replace with specific image if you have one
  static const String kCoconutImage = 'assets/images/banner2.jpg';   // Replace with specific image if you have one
  static const String kFruitImage = 'assets/images/cate-1.jpg';     // Replace with specific image if you have one

  // ---------------------------------------------------------------------------
  // 🎨 THEME COLORS
  // ---------------------------------------------------------------------------
  static const Color kPrimaryGreen = Color(0xFF2E7D32);
  static const Color kAccentLime = Color(0xFFC6FF00);
  static const Color kCreamBackground = Color(0xFFFAFCF8);
  static const Color kSurfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCreamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Good Morning,',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              'Fresh Explorer 👋',
              style: TextStyle(
                  color: kPrimaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // 🌱 HERO
          _buildImmersiveHero(),

          const SizedBox(height: 32),

          // ✨ VALUE PROPS
          _buildSectionHeader('Why Cane & Tender?', 'Pure nature in a bottle'),
          const SizedBox(height: 16),
          _buildInfoRow(),

          const SizedBox(height: 32),

          // 🥥 INGREDIENTS
          _buildSectionHeader('Our Ingredients', 'Sourced from the best farms'),
          const SizedBox(height: 16),
          _buildIngredientScroll(),

          const SizedBox(height: 32),

          // 💡 FACTS
          _buildSectionHeader('Did you know?', 'Health tidbits for you'),
          const SizedBox(height: 16),
          _buildFactCards(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // SECTIONS
  // ------------------------------------------------------------------

  Widget _buildImmersiveHero() {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimaryGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: const DecorationImage(
              // ✅ USES LOCAL ASSET
              image: AssetImage(kHeroBgImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccentLime,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '#1 Best Seller',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pure. Fresh. Natural.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Discover the goodness of sugarcane, coconut & fruits.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    final items = [
      ('No Sugar', Icons.spa_outlined),
      ('Pressed', Icons.water_drop_outlined),
      ('Hygienic', Icons.verified_user_outlined),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((e) {
        return Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: kSurfaceWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(e.$2, color: kPrimaryGreen, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                e.$1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientScroll() {
    final items = [
      ('Sugarcane', 'Energy', kSugarcaneImage),
      ('Coconut', 'Hydrate', kCoconutImage),
      ('Apple', 'Vitamin', kFruitImage),
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          return Container(
            width: 130,
            decoration: BoxDecoration(
              color: kSurfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    // ✅ USES LOCAL ASSET
                    child: Image.asset(
                      items[i].$3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          items[i].$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          items[i].$2,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFactCards() {
    final facts = [
      'Sugarcane juice helps reduce dehydration immediately.',
      'Coconut water is rich in natural electrolytes.',
      'Fresh cold-pressed juices boost immunity naturally.',
    ];

    return Column(
      children: facts.map((fact) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 4,
                decoration: BoxDecoration(
                  color: kAccentLime,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fact,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}