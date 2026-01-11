import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 16),

        // 🌱 HERO
        _hero(),

        const SizedBox(height: 24),

        _sectionTitle('Why Cane & Tender'),
        _infoCards(),

        const SizedBox(height: 28),

        _sectionTitle('Explore Ingredients'),
        _ingredientRow(),

        const SizedBox(height: 28),

        _sectionTitle('Did you know?'),
        _facts(),

        const SizedBox(height: 32),
      ],
    );
  }

  // ------------------------------------------------------------------
  // SECTIONS
  // ------------------------------------------------------------------

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF81C784),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pure.\nFresh.\nNatural.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover the goodness of sugarcane, coconut and fruits 🍹',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.eco,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _infoCards() {
    final items = [
      ('No added sugar', Icons.block),
      ('Freshly pressed', Icons.local_drink),
      ('Hygienic process', Icons.verified),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: items.map((e) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    e.$2,
                    color: const Color(0xFF66BB6A),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.$1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ingredientRow() {
    final items = [
      ('Sugarcane', 'Energy booster 🌱'),
      ('Coconut', 'Natural hydration 🥥'),
      ('Fruits', 'Vitamin rich 🍎'),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          return Container(
            width: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[i].$1,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF33691E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  items[i].$2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }

  Widget _facts() {
    final facts = [
      'Sugarcane juice helps reduce dehydration 💧',
      'Coconut water is rich in electrolytes 🥥',
      'Fresh juices boost immunity naturally 🌱',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: facts.map((fact) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF81C784),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fact,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF33691E),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
