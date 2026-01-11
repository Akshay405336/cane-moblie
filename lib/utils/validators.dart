/// lib/utils/validators.dart
class Validators {
  /* ================================================= */
  /* PHONE                                             */
  /* ================================================= */

  /// Validates raw phone input (before normalization)
  static bool isValidPhoneInput(String input) {
    final value = input.trim();

    // Only digits allowed (user input stage)
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return false;
    }

    // Indian phone number length
    if (value.length != 10) {
      return false;
    }

    return true;
  }

  /* ================================================= */
  /* OTP                                               */
  /* ================================================= */

  /// OTP must be exactly 6 digits
  static bool isValidOtp(String input) {
    return RegExp(r'^\d{6}$').hasMatch(input.trim());
  }

  /* ================================================= */
  /* GENERIC                                           */
  /* ================================================= */

  static bool isNotEmpty(String input) {
    return input.trim().isNotEmpty;
  }
}
