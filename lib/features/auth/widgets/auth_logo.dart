import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Image.asset(
        'assets/logo/2.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
