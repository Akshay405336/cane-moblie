import 'package:flutter/material.dart';
import 'home_colors.dart';

class HomeTextStyles {
  /* ================= HEADINGS ================= */

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: HomeColors.textDark,
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
  );

  /* ================= PRODUCT ================= */

  static const TextStyle productName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: HomeColors.textDark,
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: HomeColors.priceGreen,
  );

  static const TextStyle originalPrice = TextStyle(
    fontSize: 12,
    color: HomeColors.textGrey,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle discount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: HomeColors.discountRed,
  );

  /* ================= BUTTON ================= */

  static const TextStyle addButton = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: HomeColors.primaryGreen,
  );
}
