/// lib/routes.dart
import 'package:flutter/material.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';

class AppRoutes {
  /* ================================================= */
  /* ROUTE NAMES                                      */
  /* ================================================= */

  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';

  /* ================================================= */
  /* ROUTE MAP                                        */
  /* ================================================= */

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    otp: (_) => const OtpScreen(),
    home: (_) => const HomeScreen(),
  };
}
