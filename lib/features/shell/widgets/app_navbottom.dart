import 'package:flutter/material.dart';

import '../../auth/state/auth_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';

class AppNavBottom extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBottom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (_, __) {
        final isLoggedIn = AuthController.instance.isLoggedIn;

        /// ⭐ SINGLE SOURCE
        final cartController = isLoggedIn
            ? CartController.instance
            : LocalCartController.instance;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FFF8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: const Color(0xFF9E9E9E),
            items: [
              /* HOME */
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),

              /* ================= CART WITH BADGE ================= */

              BottomNavigationBarItem(
                icon: _CartIcon(
                  controller: cartController,
                  active: false,
                ),
                activeIcon: _CartIcon(
                  controller: cartController,
                  active: true,
                ),
                label: 'Cart',
              ),

              /* ================= ORDERS (UPDATED) ================= */
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), // ✅ Changed Icon
                activeIcon: Icon(Icons.shopping_bag),    // ✅ Active Icon
                label: 'Orders',                         // ✅ Renamed Label
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.store_outlined),
                label: 'Store',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.eco_outlined),
                label: 'Explore',
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================================================= */
/* CART ICON (clean + reusable)                      */
/* ================================================= */

class _CartIcon extends StatelessWidget {
  final dynamic controller;
  final bool active;

  const _CartIcon({
    required this.controller,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, __, ___) {
        final count = controller.itemCount as int;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              active
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
            ),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: _Badge(count: count),
              ),
          ],
        );
      },
    );
  }
}

/* ================================================= */
/* BADGE                                             */
/* ================================================= */

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}