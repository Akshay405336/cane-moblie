import 'package:flutter/material.dart';

import 'routes.dart';
import './features/home/services/product_socket_service.dart';
import './features/home/services/category_socket_service.dart';
import './utils/app_lifecycle_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔄 App lifecycle handling
  WidgetsBinding.instance.addObserver(
    AppLifecycleHandler(),
  );

  // 🔥 Warm up sockets early
  ProductSocketService.connect();
  CategorySocketService.connect();

  runApp(const CaneAndTenderApp());
}

class CaneAndTenderApp extends StatelessWidget {
  const CaneAndTenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cane & Tender',

      /* -------------------------------------------------- */
      /* 🌱 SUGARCANE GREEN THEME                           */
      /* -------------------------------------------------- */
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE8F5E9),
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /* -------------------------------------------------- */
      /* ROUTING                                           */
      /* -------------------------------------------------- */
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
