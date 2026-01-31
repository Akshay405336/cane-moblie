import 'package:flutter/material.dart';
import 'home_colors.dart';

class HomeTextStyles {
  /* ================= HEADINGS ================= */

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: HomeColors.textDark,
    letterSpacing: -0.5,
  );

  static const TextStyle offerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: HomeColors.primaryGreen,
  );

  /* ================= BODY ================= */

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: HomeColors.textDark,
  );

  static const TextStyle bodyGrey = TextStyle(
    fontSize: 13,
    color: HomeColors.textGrey,
    fontWeight: FontWeight.w400,
  );

  /* ================= PRODUCT ================= */

  static const TextStyle productName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: HomeColors.textDark,
    height: 1.2, // Better line height for 2 lines
  );

  static const TextStyle unit = TextStyle(
    fontSize: 11,
    color: HomeColors.textGrey,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: HomeColors.textDark, // Modern apps use black for price
  );

  static const TextStyle originalPrice = TextStyle(
    fontSize: 11,
    color: HomeColors.textLightGrey,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle discount = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  /* ================= BUTTON ================= */

  static const TextStyle addButton = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: HomeColors.primaryGreen,
  );
}