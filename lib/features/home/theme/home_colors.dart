import 'package:flutter/material.dart';

class HomeColors {
  /* ================= PRIMARY ================= */

  static const Color primaryGreen = Color(0xFF0C9C48); // Deep professional green
  static const Color darkGreen = Color(0xFF065F2C);

  /* ================= BACKGROUNDS ================= */

  // Top pastry green
  static const Color greenPastry = Color(0xFFE8F5E9);

  // Creamy white (search, chips)
  static const Color creamyWhite = Color(0xFFF8F9FA);

  // Full white content area
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Light grey background for icons/cards
  static const Color lightGrey = Color(0xFFF2F4F7);
  
  // New: Very subtle background for the app
  static const Color background = Color(0xFFF5F7FA);

  /* ================= GRADIENTS ================= */

  static const LinearGradient greenGradient = LinearGradient(
    colors: [
      Color(0xFF0C9C48),
      Color(0xFF4CAF50),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /* ================= TEXT ================= */

  static const Color textDark = Color(0xFF1A1C1E); // Softer than pure black
  static const Color textGrey = Color(0xFF757D8A); // Readable grey
  static const Color textLightGrey = Color(0xFF9EA6B0);

  /* ================= PRICE & OFFERS ================= */

  static const Color priceGreen = Color(0xFF10893E);
  static const Color discountRed = Color(0xFFE53935);

  /* ================= BORDERS & SHADOWS ================= */

  static const Color divider = Color(0xFFEEF0F2);
  static const Color border = Color(0xFFE0E0E0);
  
  // Premium Shadow
  static Color shadow = const Color(0xFF000000).withOpacity(0.06);
}