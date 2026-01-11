import 'package:flutter/material.dart';

class ReorderPage extends StatelessWidget {
  const ReorderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔁 ICON
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.history,
                size: 44,
                color: Color(0xFF43A047),
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            const Text(
              'No reorders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 8),

            // SUBTITLE
            const Text(
              'Once you place your first order,\nyou’ll see it here for quick reordering 🍹',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF558B2F),
              ),
            ),

            const SizedBox(height: 28),

            // CTA (NON-CLICKABLE DUMMY)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Start your first order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // FOOTNOTE
            const Text(
              'Fresh sugarcane & juices await 🌱',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
