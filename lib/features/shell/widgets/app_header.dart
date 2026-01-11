import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../../../utils/location_state.dart';
import '../../../utils/app_toast.dart';
import '../../auth/services/session_api.dart';
import 'location_bottom_sheet.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAuthChanged;

  const AppHeader({
    Key? key,
    required this.onAuthChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.isAuthenticated;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FFF8), // creamy white
              Color(0xFFE8F5E9), // light green wash
            ],
          ),
        ),
      ),

      // 📍 LOCATION DROPDOWN (PRIMARY)
      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openLocationSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SMALL LABEL
              const Text(
                'Delivering to',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7CB342),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              // BIG LOCATION / SHIMMER
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
                    child: LocationState.isDetecting
                        ? _locationShimmer()
                        : Text(
                            LocationState.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
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

      // 👤 USER ICON
      actions: [
        IconButton(
          splashRadius: 22,
          icon: Icon(
            isLoggedIn ? Icons.account_circle : Icons.person_outline,
            size: 26,
            color: const Color(0xFF2E7D32),
          ),
          onPressed: () async {
            if (!isLoggedIn) {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.login,
              );

              if (result == true) {
                onAuthChanged();
              }
            } else {
              _showUserSheet(context);
            }
          },
        ),
      ],
    );
  }

  /// ✨ SHIMMER FOR LOCATION
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

  /// 📍 LOCATION SHEET
  void _openLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return LocationBottomSheet(
          onUseCurrentLocation: () async {
            // handled in AppLayout
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /// 👤 USER MENU
  void _showUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.person),
                title: Text('Account'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await SessionApi.logout();
                  AuthState.reset();
                  AppToast.info('Logged out');

                  Navigator.pop(context);
                  onAuthChanged();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
