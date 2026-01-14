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
    return AnimatedBuilder(
      animation: LocationHeaderListenable(),
      builder: (context, _) {
        final isLoggedIn = AuthState.isAuthenticated;
        final isDetecting = LocationState.isDetecting;
        final hasLocation = LocationState.hasPersistedLocation;

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
            onTap: (!isDetecting && hasLocation)
                ? onLocationTap
                : null,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                          duration: const Duration(
                              milliseconds: 250),
                          child: isDetecting
                              ? _locationShimmer()
                              : Text(
                                  LocationState.address,
                                  key: ValueKey(
                                    LocationState.address,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        Color(0xFF1B5E20),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
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
                if (!isLoggedIn) {
                  final result =
                      await Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );

                  if (result == true) {
                    onAuthChanged();
                  }
                  return;
                }

                Navigator.pushNamed(
                  context,
                  AppRoutes.profile,
                );
              },
            ),
          ],
        );
      },
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

/// --------------------------------------------------
/// Lightweight listenable for header refresh
/// --------------------------------------------------
class LocationHeaderListenable extends ChangeNotifier {
  LocationHeaderListenable() {
    _tick();
  }

  void _tick() async {
    bool lastDetecting = LocationState.isDetecting;
    String lastAddress = LocationState.address;

    while (true) {
      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      if (lastDetecting != LocationState.isDetecting ||
          lastAddress != LocationState.address) {
        lastDetecting = LocationState.isDetecting;
        lastAddress = LocationState.address;
        notifyListeners();
      }
    }
  }
}
