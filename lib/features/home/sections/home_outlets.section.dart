import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../store/models/outlet.model.dart';
// ⭐ IMPORT THE NEW WIDGET
import '../widgets/store_product_list.widget.dart'; 

import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeOutletsSection extends StatelessWidget {
  final bool loading;
  final List<Outlet> outlets;
  // 🔥 NEW: Selection state passed from HomeScreen
  final String selectedCategoryId;

  const HomeOutletsSection({
    super.key,
    required this.loading,
    required this.outlets,
    required this.selectedCategoryId, // 🔥 Required for product filtering
  });

  @override
  Widget build(BuildContext context) {
    // ⭐ DEBUG LOG (very useful)
    debugPrint(
      '🏪 HomeOutletsSection → loading=$loading | outlets=${outlets.length} | filter=$selectedCategoryId',
    );

    return Column(
      key: const ValueKey('home-outlets-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeSpacing.sm),

        const _Header(),

        const SizedBox(height: HomeSpacing.md),

        /* ================= LOADING ================= */

        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(HomeSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          )

        /* ================= EMPTY ================= */

        else if (outlets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(HomeSpacing.md),
            child: Text(
              'No stores available nearby',
              style: HomeTextStyles.bodyGrey,
            ),
          )

        /* ================= LIST ================= */

        else
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeSpacing.md,
            ),

            /// ⭐ better than Column(for loop)
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: outlets.length,
              separatorBuilder: (_, __) =>
                  // Increased spacing to handle the larger cards
                  const SizedBox(height: HomeSpacing.xl),
              itemBuilder: (_, index) {
                final outlet = outlets[index];

                // ⭐ UPDATED: Passing the selectedCategoryId to enable local product filtering
                return StoreWithProductsWidget(
                  outlet: outlet,
                  selectedCategoryId: selectedCategoryId, 
                );
              },
            ),
          ),
      ],
    );
  }
}

/* ================================================= */
/* HEADER                                            */
/* ================================================= */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HomeSpacing.md,
      ),
      child: Text(
        'Nearby Stores',
        style: HomeTextStyles.sectionTitle,
      ),
    );
  }
}