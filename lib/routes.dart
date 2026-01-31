import 'package:flutter/material.dart';

import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';

import 'features/shell/app_layout.dart';

/* ================= PROFILE ================= */

import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/saved_addresses_screen.dart';

/* ================= SAVED ADDRESS ================= */

import 'features/saved_address/screens/add_edit_address_screen.dart';

/* ================= CHECKOUT ================= */

import 'features/checkout/screens/checkout_screen.dart';

/* ================= ORDERS ================= */

import 'features/orders/screens/order_details_screen.dart';
import 'features/orders/screens/my_orders_screen.dart'; // <--- ADDED IMPORT

class AppRoutes {
  /* ================================================= */
  /* ROUTE NAMES                                       */
  /* ================================================= */

  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';

  // 👤 PROFILE
  static const profile = '/profile';
  static const savedAddresses = '/saved-addresses';

  // 📍 ADDRESS
  static const addAddress = '/add-address';

  // 🛒 CHECKOUT
  static const checkout = '/checkout';

  // 📦 ORDERS
  static const myOrders = '/my-orders';        // <--- ADDED ROUTE NAME
  static const orderDetails = '/order-details';

  /* ================================================= */
  /* ROUTES                                            */
  /* ================================================= */

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    otp: (_) => const OtpScreen(),

    // 🏠 MAIN APP
    home: (_) => const AppLayout(),

    // 👤 PROFILE
    profile: (_) => const ProfileScreen(),
    savedAddresses: (_) => const SavedAddressesScreen(),

    // 📍 ADDRESS
    addAddress: (_) => const AddEditAddressScreen(),

    // 🛒 CHECKOUT
    checkout: (_) => const CheckoutScreen(),

    // 📦 ORDERS
    myOrders: (_) => const MyOrdersScreen(),     // <--- ADDED ROUTE BUILDER
    orderDetails: (_) => const OrderDetailsScreen(),
  };
}