/// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../utils/app_toast.dart';
import '../../../utils/auth_required_action.dart';
import '../../../utils/auth_state.dart';
import '../../auth/services/session_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure UI reflects latest auth state
    setState(() {});
  }

  Future<void> _logout() async {
    await SessionApi.logout();
    AuthState.reset();

    AppToast.info('Logged out');

    if (!mounted) return;

    // Go back to Home as guest
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }

  Future<void> _checkout() async {
    await AuthRequiredAction.run(
      context,
      action: () async {
        AppToast.success('Proceeding to checkout 💳');
      },
    );

    // After login, refresh UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Cane & Tender',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isLoggedIn)
            TextButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );

                // Login completed → refresh UI
                if (result == true && mounted) {
                  setState(() {});
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),

            Text(
              isLoggedIn
                  ? 'Welcome back 🌱'
                  : 'Browsing as Guest 🌱',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isLoggedIn
                  ? 'You can place orders'
                  : 'Login required only at checkout',
              style: const TextStyle(
                color: Color(0xFF388E3C),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
