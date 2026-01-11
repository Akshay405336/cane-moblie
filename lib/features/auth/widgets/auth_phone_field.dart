import 'package:flutter/material.dart';
import '../theme/auth_colors.dart';

class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;

  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: focusNode.hasFocus
                ? AuthColors.primary.withOpacity(0.35)
                : AuthColors.shadow,
            blurRadius: focusNode.hasFocus ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 10,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Text(
              '+91 |',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          hintText: 'Enter your number',
          suffixIcon: controller.text.isEmpty
              ? null
              : Icon(
                  isValid ? Icons.check_circle : Icons.close,
                  color: isValid ? AuthColors.primary : Colors.grey,
                ),
        ),
      ),
    );
  }
}
