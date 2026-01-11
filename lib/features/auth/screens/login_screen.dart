/// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';

import '../../../utils/validators.dart';
import '../../../utils/app_toast.dart';
import '../../../routes.dart';
import '../services/customer_auth_api.dart';

// 🔽 UI system imports
import '../widgets/auth_skip_button.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_phone_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_terms_text.dart';
import '../theme/auth_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    setState(() {
      _isValid = Validators.isValidPhoneInput(_phoneController.text);
    });
  }

  Future<void> _sendOtp() async {
    final phoneInput = _phoneController.text;

    if (!Validators.isValidPhoneInput(phoneInput)) {
      AppToast.error('Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    final success = await CustomerAuthApi.requestOtp(phoneInput);

    setState(() => _isLoading = false);

    if (!success || !mounted) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: phoneInput,
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _skipLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AuthColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          AuthSkipButton(onTap: _skipLogin),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewHeight - topPadding,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                // ✅ START FROM TOP (THIS IS THE FIX)
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  /// LOGO
                  const AuthLogo(),

                  const SizedBox(height: 32),

                  const AuthHeading(
                    title: 'Welcome back',
                    subtitle: 'Enter your number to continue',
                  ),

                  const SizedBox(height: 40),

                  AuthPhoneField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    isValid: _isValid,
                  ),

                  const SizedBox(height: 32),

                  AuthPrimaryButton(
                    text: 'Send OTP',
                    isLoading: _isLoading,
                    onPressed: _sendOtp,
                  ),

                  const SizedBox(height: 40),

                  const AuthTermsText(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
