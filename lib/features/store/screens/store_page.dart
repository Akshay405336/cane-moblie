import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 📍 HEADER TEXT
        const Text(
          'Nearby Cane & Tender Stores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5E20),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Fresh juice prepared near your location 🌱',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF558B2F),
          ),
        ),

        const SizedBox(height: 20),

        // 🏬 STORE CARDS (DUMMY)
        _storeCard(
          name: 'Cane & Tender – Indiranagar',
          distance: '1.2 km',
          status: 'Open',
        ),
        const SizedBox(height: 12),
        _storeCard(
          name: 'Cane & Tender – Koramangala',
          distance: '2.8 km',
          status: 'Open',
        ),
        const SizedBox(height: 12),
        _storeCard(
          name: 'Cane & Tender – MG Road',
          distance: '4.5 km',
          status: 'Closed',
        ),

        const SizedBox(height: 24),

        // EMPTY FOOTER
        Center(
          child: Text(
            'More stores coming soon 🍹',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _storeCard({
    required String name,
    required String distance,
    required String status,
  }) {
    final isOpen = status == 'Open';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // STORE ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Color(0xFF43A047),
            ),
          ),

          const SizedBox(width: 12),

          // STORE INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ],
            ),
          ),

          // STATUS
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOpen
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
