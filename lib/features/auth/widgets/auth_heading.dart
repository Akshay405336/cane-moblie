import 'package:flutter/material.dart';
import '../theme/auth_styles.dart';

class AuthHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: AuthTextStyles.title),
        const SizedBox(height: 8),
        Text(subtitle, style: AuthTextStyles.subtitle),
      ],
    );
  }
}
