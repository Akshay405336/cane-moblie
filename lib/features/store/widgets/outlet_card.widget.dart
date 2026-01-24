import 'package:flutter/material.dart';

import '../models/outlet.model.dart';
import '../screens/outlet_products_screen.dart';

import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';
import '../../home/theme/home_text_styles.dart';

class OutletCard extends StatelessWidget {
  final Outlet outlet;

  const OutletCard({
    super.key,
    required this.outlet,
  });

  /// safer check
  bool get _isOpen =>
      outlet.workingStatus.toUpperCase() == 'OPEN';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(HomeSpacing.radiusLg),

      /// disable tap if closed
      onTap: _isOpen
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OutletProductsScreen(outlet: outlet),
                ),
              );
            }
          : null,

      child: Container(
        padding: const EdgeInsets.all(HomeSpacing.md),
        decoration: BoxDecoration(
          color: HomeColors.pureWhite,
          borderRadius:
              BorderRadius.circular(HomeSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /* ================= ICON ================= */

            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: HomeColors.greenPastry,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront,
                color: HomeColors.primaryGreen,
                size: 26,
              ),
            ),

            const SizedBox(width: HomeSpacing.md),

            /* ================= DETAILS ================= */

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: HomeTextStyles.sectionTitle
                        .copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outlet.branch,
                    style: HomeTextStyles.bodyGrey,
                  ),
                ],
              ),
            ),

            /* ================= STATUS ================= */

            _StatusBadge(isOpen: _isOpen),
          ],
        ),
      ),
    );
  }
}

/* ================================================= */
/* STATUS BADGE                                      */
/* ================================================= */

class _StatusBadge extends StatelessWidget {
  final bool isOpen;

  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'OPEN' : 'CLOSED',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
