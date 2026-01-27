import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';

import '../../cart/state/cart_controller.dart';
import '../../cart/state/local_cart_controller.dart';

/// =================================================
/// AUTH CONTROLLER
/// Single source of truth for login state
/// =================================================
class AuthController extends ValueNotifier<bool> {
  AuthController._() : super(AuthState.isAuthenticated);

  static final instance = AuthController._();

  bool get isLoggedIn => value;

  /* ================================================= */
  /* LOGIN                                             */
  /* ================================================= */

  /// call after login success
  Future<void> login({
    required String outletId,
  }) async {
    /// 🔥 FIRST merge guest → server
    await _mergeGuestCart(outletId);

    /// 🔥 THEN switch state (avoids empty flicker)
    value = true;
  }

  /* ================================================= */
  /* LOGOUT                                            */
  /* ================================================= */

  void logout() {
    value = false;

    /// reset everything locally
    CartController.instance.clear();
    LocalCartController.instance.clear();
  }

  /* ================================================= */
  /* INTERNAL                                          */
  /* ================================================= */

  Future<void> _mergeGuestCart(String outletId) async {
    final localItems = LocalCartController.instance.items;

    if (localItems.isEmpty) {
      /// still load server cart
      await CartController.instance.load();
      return;
    }

    await CartController.instance.mergeLocalItems(
      localItems: localItems,
      outletId: outletId,
    );

    LocalCartController.instance.clear();
  }
}
