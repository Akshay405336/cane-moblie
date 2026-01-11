/// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';

import '../../../utils/validators.dart';
import '../../../utils/app_toast.dart';
import '../../../routes.dart';
import '../services/customer_auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final phoneInput = _phoneController.text;

    // UI-level validation
    if (!Validators.isValidPhoneInput(phoneInput)) {
      AppToast.error('Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    final success =
        await CustomerAuthApi.requestOtp(phoneInput);

    setState(() => _isLoading = false);

    if (!success || !mounted) return;

    // 🔑 WAIT for OTP result
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: phoneInput,
    );

    // ✅ OTP verified → close login screen
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _skipLogin() {
  if (Navigator.canPop(context)) {
    Navigator.pop(context, false);
  } else {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  }
}


  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipLogin,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Icon(
                Icons.eco,
                size: 60,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 16),

              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Enter your mobile number to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF388E3C),
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  labelText: 'Mobile Number',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
