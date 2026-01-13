import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../../../utils/location_state.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onAuthChanged;
  final VoidCallback onLocationTap;

  const AppHeader({
    Key? key,
    required this.onAuthChanged,
    required this.onLocationTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.isAuthenticated;
    final isDetecting = LocationState.isDetecting;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FFF8),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
      ),

      // 📍 LOCATION (DISPLAY ONLY)
      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDetecting ? null : onLocationTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xFF43A047),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 250),
                      child: isDetecting
                          ? _locationShimmer()
                          : Text(
                              LocationState.address,
                              key: ValueKey(
                                LocationState.address,
                              ),
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
          ),
        ),
      ),

      // 👤 PROFILE / LOGIN
      actions: [
        IconButton(
          splashRadius: 22,
          icon: Icon(
            isLoggedIn
                ? Icons.account_circle
                : Icons.person_outline,
            size: 26,
            color: const Color(0xFF2E7D32),
          ),
          onPressed: () async {
            // 🔐 NOT LOGGED IN → LOGIN
            if (!isLoggedIn) {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.login,
              );

              if (result == true) {
                onAuthChanged();
              }
              return;
            }

            // 👤 LOGGED IN → PROFILE MAIN PAGE
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // SHIMMER
  // ------------------------------------------------------------------

  Widget _locationShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.green.shade200,
      highlightColor: Colors.green.shade50,
      child: Container(
        height: 18,
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
