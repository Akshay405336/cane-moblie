import 'package:flutter/material.dart';
import '../theme/auth_styles.dart';

class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Text(
        'By continuing, you agree to our Terms & Privacy Policy',
        textAlign: TextAlign.center,
        style: AuthTextStyles.terms,
      ),
    );
  }
}
