import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../../../utils/app_toast.dart';
import '../../auth/services/session_api.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- ACCOUNT ----------------
          _ProfileTile(
            icon: Icons.person_outline,
            title: 'Account',
            onTap: () {
              AppToast.info('Account coming soon');
            },
          ),

          // ---------------- SAVED ADDRESSES ----------------
          _ProfileTile(
            icon: Icons.location_on_outlined,
            title: 'Saved addresses',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.savedAddresses,
              );
            },
          ),

          // ---------------- ORDERS ----------------
          _ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            onTap: () {
              AppToast.info('Orders coming soon');
            },
          ),

          // ---------------- PAYMENTS ----------------
          _ProfileTile(
            icon: Icons.payment_outlined,
            title: 'Payments',
            onTap: () {
              AppToast.info('Payments coming soon');
            },
          ),

          const Divider(height: 32),

          // ---------------- LOGOUT ----------------
          _ProfileTile(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () async {
              await SessionApi.logout();
              AuthState.reset();
              AppToast.info('Logged out');

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
  }
}

// =======================================================
// REUSABLE TILE
// =======================================================

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
