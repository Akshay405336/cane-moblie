import 'package:flutter/material.dart';
import '../theme/auth_colors.dart';

class AuthSkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const AuthSkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        'Skip',
        style: TextStyle(
          color: AuthColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
