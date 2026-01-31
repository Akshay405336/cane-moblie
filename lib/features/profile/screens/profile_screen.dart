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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- ACCOUNT HEADER ----------------
          // Optional: Add a small header if you have user info
           const SizedBox(height: 10),
          
          // ---------------- SAVED ADDRESSES ----------------
          _ProfileTile(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.savedAddresses);
            },
          ),

          // ---------------- ORDERS (UPDATED) ----------------
          _ProfileTile(
            icon: Icons.shopping_bag_outlined, // Better icon for orders
            title: 'My Orders',
            onTap: () {
              // ✅ Navigates to the Order List page
              Navigator.pushNamed(context, AppRoutes.myOrders);
            },
          ),

          // ---------------- PAYMENTS ----------------
          _ProfileTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {
              AppToast.info('Payments coming soon');
            },
          ),

          const Divider(height: 40, thickness: 1),

          // ---------------- LOGOUT ----------------
          _ProfileTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            textColor: Colors.red.shade600,
            iconColor: Colors.red.shade600,
            showChevron: false,
            onTap: () async {
              // Show confirmation dialog optionally
              await SessionApi.logout();
              AuthState.reset();
              
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
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
  final Color? iconColor;
  final bool showChevron;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Subtle grey background for modern feel
        tileColor: Colors.grey.shade50, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: iconColor ?? Colors.black54),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
            fontSize: 15,
          ),
        ),
        trailing: showChevron 
            ? const Icon(Icons.chevron_right, color: Colors.grey) 
            : null,
        onTap: onTap,
      ),
    );
  }
}