/// lib/utils/phone_normalizer.dart
class PhoneNormalizer {
  /// Normalizes Indian phone numbers to E.164 format.
  ///
  /// Examples:
  /// 9876543212        -> +919876543212
  /// 09876543212       -> +919876543212
  /// +91 98765 43212   -> +919876543212
  /// +91-9876543212    -> +919876543212
  static String normalizeIndian(String input) {
    var phone = input.trim();

    // Remove spaces, hyphens, brackets
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Remove leading 0
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // Add country code if missing
    if (!phone.startsWith('+')) {
      phone = '+91$phone';
    }

    return phone;
  }

  /// Simple validity check (post-normalization)
  static bool isValidIndian(String normalizedPhone) {
    return RegExp(r'^\+91\d{10}$').hasMatch(normalizedPhone);
  }
}
