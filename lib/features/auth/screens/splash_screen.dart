/// lib/features/auth/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../utils/auth_state.dart';
import '../services/session_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Minimum splash time
    await Future.delayed(const Duration(seconds: 1));

    // Check session with backend
    final isLoggedIn = await SessionApi.me();

    if (!mounted) return;

    if (isLoggedIn) {
      // ✅ Logged-in user
      AuthState.setAuthenticated(true);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );
    } else {
      // 🟡 Guest user
      AuthState.setGuest();

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF03B602), // sugarcane green
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Cane & Tender',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
