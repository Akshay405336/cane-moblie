/// lib/network/api_endpoints.dart
class ApiEndpoints {
  /* ================================================= */
  /* AUTH – OTP (CUSTOMER)                              */
  /* ================================================= */

  static const String requestCustomerOtp =
      '/auth/customer/otp/request';

  static const String verifyCustomerOtp =
      '/auth/customer/otp/verify';

  /* ================================================= */
  /* AUTH – SESSION                                    */
  /* ================================================= */

  static const String refreshSession =
      '/auth/session/refresh';

  static const String logout =
      '/auth/session/logout';

  static const String me =
      '/auth/session/me';
}
