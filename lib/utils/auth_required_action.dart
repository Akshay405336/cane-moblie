/// lib/utils/auth_required_action.dart
import 'package:flutter/material.dart';

import '../routes.dart';
import 'auth_state.dart';

typedef ProtectedAction = Future<void> Function();

class AuthRequiredAction {
  AuthRequiredAction._();

  /* ================================================= */
  /* RUN ACTION WITH AUTH CHECK                        */
  /* ================================================= */

  static Future<void> run(
    BuildContext context, {
    required ProtectedAction action,
  }) async {
    // If already logged in → run immediately
    if (AuthState.isAuthenticated) {
      await action();
      return;
    }

    // Guest user → redirect to login
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.login,
    );

    // Login screen should return true on success
    if (result == true && AuthState.isAuthenticated) {
      await action();
    }
  }
}
