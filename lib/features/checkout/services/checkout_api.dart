import 'package:flutter/foundation.dart';
import '../../../core/network/http_client.dart';
import '../models/checkout_summary.model.dart';
import '../../orders/models/order.model.dart';

class CheckoutApi {
  CheckoutApi._();

  static final _dio = AppHttpClient.dio;

  /* ================================================= */
  /* GET SUMMARY (🔥 outletId REQUIRED)                */
  /* ================================================= */

  static Future<CheckoutSummary?> getSummary({
    required String addressId,
    required String outletId,
  }) async {
    try {
      debugPrint('💳 GET /checkout/summary/$addressId?outletId=$outletId');

      final res = await _dio.get(
        '/checkout/summary/$addressId',
        queryParameters: {
          'outletId': outletId,
        },
      );

      if (res.data != null && res.data['success'] == true) {
        return CheckoutSummary.fromJson(res.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Checkout Summary Failed: $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* START CHECKOUT                                    */
  /* ================================================= */

  static Future<Map<String, dynamic>> startCheckout({
    required String outletId,
    required String addressId,
  }) async {
    try {
      debugPrint('💳 POST /checkout/start');

      final res = await _dio.post(
        '/checkout/start',
        data: {
          'outletId': outletId,
          'savedAddressId': addressId,
        },
      );

      // 🔥 NOTE: Backend MUST return 'razorpayOrderId', 'key', and 'amount' here
      return res.data['data']; 
    } catch (e) {
      debugPrint('❌ Start Checkout Failed: $e');
      throw Exception('Could not initiate checkout');
    }
  }

  /* ================================================= */
  /* CONFIRM PAYMENT                                   */
  /* ================================================= */

  static Future<void> confirmPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      debugPrint('💳 POST /payments/$paymentId/confirm');
      
      await _dio.post(
        '/payments/$paymentId/confirm',
        data: {
          // Required for backend verification
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );
    } catch (e) {
      debugPrint('❌ Payment Failed: $e');
      throw Exception('Payment verification failed');
    }
  }

  /* ================================================= */
  /* GET ORDER                                         */
  /* ================================================= */

  static Future<Order> getOrder(String orderId) async {
    try {
      final res = await _dio.get('/orders/$orderId');
      return Order.fromJson(res.data['data']);
    } catch (e) {
      debugPrint('❌ Get Order Failed: $e');
      throw Exception('Could not fetch order details');
    }
  }
}