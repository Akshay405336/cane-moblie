/// lib/features/auth/services/session_api.dart
import 'package:dio/dio.dart';

import '../../../network/api_endpoints.dart';
import '../../../network/http_client.dart';
import '../../../utils/api_error_handler.dart';
import '../../../utils/app_toast.dart';
import '../../../utils/secure_storage.dart';

class SessionApi {
  /* ================================================= */
  /* SESSION: ME                                      */
  /* ================================================= */

  /// Checks if current session is valid
  /// Returns true if authenticated
  static Future<bool> me() async {
    try {
      final response = await AppHttpClient.dio.get(
        ApiEndpoints.me,
      );

      final success = response.data['success'] == true;
      return success;
    } on DioException catch (_) {
      // Any error here = unauthenticated
      return false;
    }
  }

  /* ================================================= */
  /* SESSION: LOGOUT                                  */
  /* ================================================= */

  static Future<void> logout() async {
    try {
      await AppHttpClient.dio.post(
        ApiEndpoints.logout,
      );
    } on DioException catch (e) {
      // Even if backend fails, we logout locally
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.info(message);
    } finally {
      // Always clear local session
      await SecureStorage.clearAuth();
    }
  }
}
