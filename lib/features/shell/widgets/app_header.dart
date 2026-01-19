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
    /// 🔐 SAFETY NET
    LocationHeaderController.instance.sync();

    return ValueListenableBuilder<LocationHeaderState>(
      valueListenable: LocationHeaderController.instance,
      builder: (context, state, _) {
        final isLoggedIn = AuthState.isAuthenticated;
        final isDetecting = state.isDetecting;
        final hasLocation = state.hasLocation;

        return AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFE6F4EA), // ✅ MATCH HOME
          
          /* ================= LOCATION ================= */

          title: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap:
                (!isDetecting && hasLocation) ? onLocationTap : null,
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
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF558B2F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /* ================= PROFILE ICON ================= */

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () async {
                  if (!isLoggedIn) {
                    final result =
                        await Navigator.pushNamed(
                      context,
                      AppRoutes.login,
                    );
                    if (result == true) onAuthChanged();
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
                    color: Colors.white, // ✅ WHITE BG
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
                    color: const Color(0xFF03B602), // ✅ SAME GREEN AS HOME ICON
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // SHIMMER
  // --------------------------------------------------

  Widget _locationShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFB7E1C2),
      highlightColor: const Color(0xFFE9F9ED),
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

/// ==================================================
/// HEADER STATE (IMMUTABLE)
/// ==================================================
class LocationHeaderState {
  final bool isDetecting;
  final bool hasLocation;

  const LocationHeaderState({
    required this.isDetecting,
    required this.hasLocation,
  });
}

/// ==================================================
/// SINGLE SOURCE OF TRUTH (NO POLLING)
/// ==================================================
class LocationHeaderController
    extends ValueNotifier<LocationHeaderState> {
  LocationHeaderController._()
      : super(
          LocationHeaderState(
            isDetecting: LocationState.isDetecting,
            hasLocation:
                LocationState.hasPersistedLocation,
          ),
        );

  static final instance = LocationHeaderController._();

  void sync() {
    value = LocationHeaderState(
      isDetecting: LocationState.isDetecting,
      hasLocation:
          LocationState.hasPersistedLocation,
    );
  }
}
