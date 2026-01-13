import 'package:flutter/material.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/shell/app_layout.dart';

// 🧑 PROFILE
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/saved_addresses_screen.dart';

class AppRoutes {
  /* ================================================= */
  /* ROUTE NAMES                                      */
  /* ================================================= */

  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';

  // 👤 PROFILE
  static const String profile = '/profile';
  static const String savedAddresses = '/saved-addresses';

  /* ================================================= */
  /* ROUTE MAP                                        */
  /* ================================================= */

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    otp: (_) => const OtpScreen(),

    // 🏠 MAIN APP
    home: (_) => const AppLayout(),

    // 👤 PROFILE
    profile: (_) => const ProfileScreen(),
    savedAddresses: (_) => const SavedAddressesScreen(),
  };
}
