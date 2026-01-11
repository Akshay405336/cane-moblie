/// lib/utils/api_error_handler.dart
import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// Returns a user-friendly message from Dio error
  static String getMessage(DioException error) {
    print('================ API ERROR DEBUG ================');
    print('❌ DioException type   : ${error.type}');
    print('❌ DioException message: ${error.message}');
    print('❌ Request URL         : ${error.requestOptions.uri}');
    print('❌ Request method      : ${error.requestOptions.method}');
    print('❌ Status code         : ${error.response?.statusCode}');
    print('❌ Raw response data   : ${error.response?.data}');
    print('=================================================');

    final raw = error.response?.data;

    if (raw == null) {
      print('⚠️ RESPONSE DATA IS NULL');
      return _genericMessage();
    }

    Map<String, dynamic>? data;

    // Case 1: direct map
    if (raw is Map<String, dynamic>) {
      data = raw;
      print('✅ Raw is Map<String, dynamic>');

      // Case 2: wrapped error
      if (raw['error'] is Map<String, dynamic>) {
        data = raw['error'] as Map<String, dynamic>;
        print('✅ Found wrapped error object');
      }
    } else {
      print('❌ Raw response is NOT a Map');
      return _genericMessage();
    }

    final code = data['code'];
    final message = data['message'];
    final metadata = data['metadata'];

    print('➡️ Parsed code     : $code');
    print('➡️ Parsed message  : $message');
    print('➡️ Parsed metadata : $metadata');

    switch (code) {
      /* ================================================= */
      /* OTP REQUEST                                      */
      /* ================================================= */

      case 'OTP_ALREADY_SENT':
        final retryAfter =
            metadata is Map ? metadata['retryAfterSeconds'] : null;
        if (retryAfter != null) {
          return 'OTP already sent. Try again in ${_formatSeconds(retryAfter)}';
        }
        return 'OTP already sent. Please wait before retrying';

      /* ================================================= */
      /* OTP VERIFY                                       */
      /* ================================================= */

      case 'INVALID_OTP':
        final remaining =
            metadata is Map ? metadata['remainingAttempts'] : null;
        if (remaining != null) {
          return 'Invalid OTP. $remaining attempts remaining';
        }
        return 'Invalid OTP';

      case 'OTP_BLOCKED':
        final retryAfter =
            metadata is Map ? metadata['retryAfterSeconds'] : null;
        if (retryAfter != null) {
          return 'Too many attempts. Try again in ${_formatSeconds(retryAfter)}';
        }
        return 'OTP temporarily blocked';

      /* ================================================= */
      /* AUTH / SESSION                                   */
      /* ================================================= */

      case 'INVALID_CREDENTIALS':
        return 'Invalid phone number';

      case 'UNAUTHORIZED':
      case 'INVALID_AUTH_CONTEXT':
        return 'Session expired. Please login again';

      /* ================================================= */
      /* FALLBACK                                         */
      /* ================================================= */

      default:
        print('⚠️ UNKNOWN ERROR CODE, FALLBACK');
        return message?.toString() ?? _genericMessage();
    }
  }

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  static String _genericMessage() {
    return 'Something went wrong. Please try again';
  }

  static String _formatSeconds(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }

    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}m';
    }

    final hours = minutes ~/ 60;
    return '${hours}h';
  }
}
