import 'package:flutter/material.dart';

class HomeColors {
  /* ================= PRIMARY ================= */

  static const Color primaryGreen = Color(0xFF03B602);

  /* ================= BACKGROUNDS ================= */

  // Top pastry green
  static const Color greenPastry = Color(0xFFE9F9ED);

  // Creamy white (search, chips)
  static const Color creamyWhite = Color(0xFFF6FBF7);

  // Full white content area
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Light grey background for icons/cards
  static const Color lightGrey = Color(0xFFF1F3F5);

  /* ================= GRADIENTS ================= */

  static const LinearGradient greenGradient = LinearGradient(
    colors: [
      Color(0xFF03B602),
      Color(0xFF5FD068),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /* ================= TEXT ================= */

  static const Color textDark = Color(0xFF1C1C1C);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLightGrey = Color(0xFF9CA3AF);

  /* ================= PRICE & OFFERS ================= */

  static const Color priceGreen = Color(0xFF03B602);
  static const Color discountRed = Color(0xFFE53935);

  /* ================= BORDERS & DIVIDERS ================= */

  static const Color divider = Color(0xFFE5E7EB);
}
