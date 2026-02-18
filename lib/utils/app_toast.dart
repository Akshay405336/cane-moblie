/// lib/utils/app_toast.dart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AppToast {
  // Primary sugarcane green
  static const Color _green = Color(0xFF2E7D32); // deep cane green
  static const Color _lightGreen = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF1B5E20);

  static void show(
    String message, {
    ToastType type = ToastType.info,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _backgroundColor(type),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /* ================================================= */
  /* SHORTCUTS                                         */
  /* ================================================= */

  static void success(String message) {
    show(message, type: ToastType.success);
  }

  static void info(String message) {
    show(message, type: ToastType.info);
  }

  static void error(String message) {
    // Still green, just darker (no red)
    show(message, type: ToastType.error);
  }

  /* ================================================= */
  /* INTERNAL                                          */
  /* ================================================= */

  static Color _backgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _lightGreen;
      case ToastType.error:
        return _darkGreen;
      case ToastType.info:
      return _green;
    }
  }
}

enum ToastType {
  success,
  info,
  error,
}
