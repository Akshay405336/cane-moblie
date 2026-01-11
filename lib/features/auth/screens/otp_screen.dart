/// lib/features/auth/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../utils/app_toast.dart';
import '../../../utils/validators.dart';
import '../../../utils/auth_state.dart';
import '../services/customer_auth_api.dart';

// UI system
import '../widgets/auth_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../theme/auth_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;

  // Resend timer
  static const int _initialCooldown = 60;
  int _cooldownSeconds = _initialCooldown;
  Timer? _timer;

  late final String _phone;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phone = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _startCooldown() {
    _timer?.cancel();
    _cooldownSeconds = _initialCooldown;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (!Validators.isValidOtp(otp)) {
      AppToast.error('Enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    final success = await CustomerAuthApi.verifyOtp(
      rawPhone: _phone,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      AuthState.setAuthenticated(true);
      Navigator.pop(context, true);
    }
  }

  Future<void> _resendOtp() async {
    AppToast.info('Requesting new OTP...');
    await CustomerAuthApi.requestOtp(_phone);
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AuthColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AuthColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                /// LOGO
                const AuthLogo(),

                const SizedBox(height: 32),

                const Text(
                  'OTP Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Please type the OTP verification code sent to\n',
                      ),
                      TextSpan(
                        text: '+91 $_phone',
                        style: const TextStyle(
                          color: AuthColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// OTP INPUT
                Pinput(
                  controller: _otpController,
                  length: 6,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration!.copyWith(
                      boxShadow: [
                        BoxShadow(
                          color:
                              AuthColors.primary.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// RESEND
                _cooldownSeconds > 0
                    ? Text(
                        'Resend code in $_cooldownSeconds s',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AuthColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                const SizedBox(height: 32),

                /// VERIFY BUTTON
                AuthPrimaryButton(
                  text: 'Verify Code',
                  isLoading: _isLoading,
                  onPressed: _verifyOtp,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
