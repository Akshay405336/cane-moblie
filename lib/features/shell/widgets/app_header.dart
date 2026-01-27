import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../routes.dart';
import '../../location/state/location_controller.dart';
import '../../../utils/auth_state.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onLocationTap;

  const AppHeader({
    super.key,
    required this.onLocationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.isAuthenticated;

    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFE6F4EA),

      /* ================================================= */
      /* LOCATION (only this part listens to controller)    */
      /* ================================================= */

      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
  debugPrint('🔥 HEADER CLICKED');
  onLocationTap();
},
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: _LocationText(),
        ),
      ),

      /* ================================================= */
      /* PROFILE                                           */
      /* ================================================= */

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              if (!isLoggedIn) {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );
                return;
              }

              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isLoggedIn
                    ? Icons.account_circle
                    : Icons.person,
                size: 22,
                color: const Color(0xFF03B602),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================================================== */
/* ⭐ Separate widget → only this rebuilds                */
/* ===================================================== */

class _LocationText extends StatelessWidget {
  const _LocationText();

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    final isDetecting = location.isDetecting;
    final hasLocation = location.hasLocation;

    final text = hasLocation
        ? location.current!.shortAddress // ⭐ new model
        : 'Select location';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivering to',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF7CB342),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),

        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 18,
              color: Color(0xFF43A047),
            ),
            const SizedBox(width: 6),

            Expanded(
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 250),
                child: isDetecting
                    ? _locationShimmer()
                    : Text(
                        text,
                        key: ValueKey(text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF558B2F),
            ),
          ],
        ),
      ],
    );
  }

  Widget _locationShimmer() {
    return Container(
      height: 18,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
