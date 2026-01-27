/// lib/features/auth/services/customer_auth_api.dart
import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../../../utils/api_error_handler.dart';
import '../../../utils/app_toast.dart';
import '../../../utils/phone_normalizer.dart';
import '../../../utils/secure_storage.dart';

class CustomerAuthApi {
  /* ================================================= */
  /* REQUEST OTP                                      */
  /* ================================================= */

  static Future<bool> requestOtp(String rawPhone) async {
    try {
      final phone =
          PhoneNormalizer.normalizeIndian(rawPhone);

      final response = await AppHttpClient.dio.post(
        ApiEndpoints.requestCustomerOtp,
        data: {
          'phone': phone,
        },
        options: Options(
          headers: {
            'x-client-type': 'mobile',
          },
        ),
      );

      if (response.data['success'] == true) {
        AppToast.success('OTP sent successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return false;
    }
  }

  /* ================================================= */
  /* VERIFY OTP                                       */
  /* ================================================= */

  static Future<bool> verifyOtp({
    required String rawPhone,
    required String otp,
  }) async {
    try {
      final phone =
          PhoneNormalizer.normalizeIndian(rawPhone);

      final response = await AppHttpClient.dio.post(
        ApiEndpoints.verifyCustomerOtp,
        data: {
          'phone': phone,
          'otp': otp,
        },
        options: Options(
          headers: {
            'x-client-type': 'mobile',
          },
        ),
      );

      final data = response.data['data'];
      if (data == null) {
        AppToast.error('Invalid server response');
        return false;
      }

      // 🔐 SAVE TOKENS (MOBILE FLOW)
      await SecureStorage.saveAuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessExpiry:
            DateTime.parse(data['accessTokenExpiresAt']),
        refreshExpiry:
            DateTime.parse(data['refreshTokenExpiresAt']),
      );

      AppToast.success('Login successful');
      return true;
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return false;
    }
  }
}
