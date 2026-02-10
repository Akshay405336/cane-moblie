import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart'; // 🔥 Import Dio for error handling
import '../../../core/network/http_client.dart';
import '../models/checkout_summary.model.dart';
import '../../orders/models/order.model.dart';

class CheckoutApi {
  CheckoutApi._();

  static final _dio = AppHttpClient.dio;

  /* ================================================= */
  /* GET SUMMARY                                       */
  /* ================================================= */
  static Future<CheckoutSummary?> getSummary({
    required String addressId,
    required String outletId,
  }) async {
    try {
      debugPrint('💳 GET /checkout/summary/$addressId?outletId=$outletId');

      final res = await _dio.get(
        '/checkout/summary/$addressId',
        queryParameters: {'outletId': outletId},
      );

      if (res.data != null && res.data['success'] == true) {
        return CheckoutSummary.fromJson(res.data['data']);
      }
      return null;
    } on DioException catch (e) {
      // 🔥 Extract message from backend if available
      final msg = e.response?.data['message'] ?? 'Failed to load summary';
      throw Exception(msg);
    }
  }

  /* ================================================= */
  /* START CHECKOUT (🔥 FIXED ERROR HANDLING)          */
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

      return res.data['data']; 
    } on DioException catch (e) {
      debugPrint('❌ Start Checkout Failed: ${e.response?.data}');
      
      // 🔥 Instead of hardcoding "Could not initiate checkout",
      // we take the real message from your backend (e.g. "Order already pending")
      final backendMessage = e.response?.data['message'] ?? 'Could not initiate checkout';
      throw Exception(backendMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred');
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
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Payment verification failed';
      throw Exception(msg);
    }
  }

  /* ================================================= */
  /* GET ORDER                                         */
  /* ================================================= */
  static Future<Order> getOrder(String orderId) async {
    try {
      final res = await _dio.get('/orders/$orderId');
      return Order.fromJson(res.data['data']);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Could not fetch order details';
      throw Exception(msg);
    }
  }
}