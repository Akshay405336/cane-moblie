import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌱 HERO BANNER
          _heroBanner(),

          const SizedBox(height: 20),

          // 🍹 CATEGORIES
          _sectionTitle('Fresh Categories'),
          _categoryRow(),

          const SizedBox(height: 24),

          // ⭐ FEATURED JUICES
          _sectionTitle('Best Sellers'),
          _juiceList(),

          const SizedBox(height: 24),

          // 🌴 SUGARCANE SPECIAL
          _sectionTitle('Sugarcane Specials'),
          _caneBanner(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // UI SECTIONS
  // ------------------------------------------------------------------

  Widget _heroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF66BB6A),
            Color(0xFF43A047),
          ],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh. Natural.\nCold Pressed.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pure sugarcane & fruit juices\nserved fresh everyday 🌱',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.local_drink,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _categoryRow() {
    final categories = [
      ('Sugarcane', Icons.eco),
      ('Fruit Juice', Icons.local_drink),
      ('Coconut', Icons.spa),
      ('Detox', Icons.favorite),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          return Container(
            width: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[i].$2,
                  size: 28,
                  color: const Color(0xFF66BB6A),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[i].$1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
      ),
    );
  }

  Widget _juiceList() {
    final juices = [
      ('Classic Cane', '₹40', Icons.eco),
      ('Mint Cane', '₹50', Icons.spa),
      ('Orange Juice', '₹60', Icons.local_drink),
      ('Apple Detox', '₹70', Icons.favorite),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  juices[i].$3,
                  color: const Color(0xFF43A047),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      juices[i].$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      juices[i].$2,
                      style: const TextStyle(
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF66BB6A),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: juices.length,
    );
  }

  Widget _caneBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.eco,
            size: 36,
            color: Color(0xFF558B2F),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '100% natural sugarcane juice\nNo sugar • No chemicals',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF33691E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
