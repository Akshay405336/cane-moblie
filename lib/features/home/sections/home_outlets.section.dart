import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../store/models/outlet.model.dart';
import '../../store/widgets/outlet_card.widget.dart';

import '../theme/home_spacing.dart';
import '../theme/home_text_styles.dart';

class HomeOutletsSection extends StatelessWidget {
  final bool loading;
  final List<Outlet> outlets;

  const HomeOutletsSection({
    super.key,
    required this.loading,
    required this.outlets,
  });

  @override
  Widget build(BuildContext context) {
    // ⭐ DEBUG LOG (very useful)
    debugPrint(
      '🏪 HomeOutletsSection → loading=$loading | outlets=${outlets.length}',
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
                  const SizedBox(height: HomeSpacing.md),
              itemBuilder: (_, index) {
                final outlet = outlets[index];

                return OutletCard(outlet: outlet);
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