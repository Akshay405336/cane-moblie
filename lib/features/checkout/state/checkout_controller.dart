import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/checkout_summary.model.dart';
import '../services/checkout_api.dart';
import '../../orders/models/order.model.dart';
import '../../cart/state/cart_controller.dart';

class CheckoutController extends ValueNotifier<CheckoutSummary?> {
  CheckoutController._() : super(null);
  static final instance = CheckoutController._();

  // =========================================================
  // 🔥 YOUR RAZORPAY KEY ID
  // =========================================================
  static const String _fallbackKey = "rzp_test_RbAfDB5uwpOElJ"; 

  late Razorpay _razorpay;
  Completer<Order?>? _checkoutCompleter;
  
  String? _currentInternalOrderId;
  String? _currentInternalPaymentId;

  bool _loading = false;
  String? _error;
  String? _outletId;

  bool get isLoading => _loading;
  String? get error => _error;

  /* ================================================= */
  /* INITIALIZATION                                    */
  /* ================================================= */

  void initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void disposeRazorpay() {
    _razorpay.clear();
  }

  /* ================================================= */
  /* BASIC STATE                                       */
  /* ================================================= */

  void setOutlet(String outletId) {
    _outletId = outletId;
  }

  void _ensureOutlet() {
    if (_outletId == null) {
      throw Exception('OutletId not set');
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> loadSummary(String addressId) async {
    _outletId ??= CartController.instance.value.outletId;
    if (_outletId == null) return;

    _setLoading(true);
    _error = null;
    try {
      final data = await CheckoutApi.getSummary(
        addressId: addressId,
        outletId: _outletId!,
      );
      value = data;
    } catch (e) {
      _error = e.toString();
      debugPrint("Checkout Load Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeAddress(String newAddressId) async {
    await loadSummary(newAddressId);
  }

  /* ================================================= */
  /* 🔥 PLACE ORDER (Corrected Error Handling)         */
  /* ================================================= */

  Future<Order?> placeOrder() async {
    if (value == null) return null;

    _outletId ??= CartController.instance.value.outletId;
    _ensureOutlet();

    _setLoading(true);
    _checkoutCompleter = Completer<Order?>();

    try {
      // 1. Call Backend to create pending order
      final data = await CheckoutApi.startCheckout(
        outletId: _outletId!,
        addressId: value!.addressId,
      );

      _currentInternalOrderId = data['orderId'];
      _currentInternalPaymentId = data['paymentId'];

      // 2. Prepare Data
      String rzpKey = data['key'] ?? _fallbackKey;
      int amount = data['amount'] ?? (value!.grandTotal * 100).toInt();

      var options = {
        'key': rzpKey,
        'amount': amount,
        'name': 'Cane & Tender',
        'description': 'Fresh Juice Order',
        'timeout': 300, 
        'prefill': {
          'contact': '9876543210', 
          'email': 'customer@example.com'
        }
      };

      if (data['razorpayOrderId'] != null && data['razorpayOrderId'].toString().isNotEmpty) {
        options['order_id'] = data['razorpayOrderId'];
      } else {
        debugPrint("⚠️ WARNING: No Razorpay Order ID from server.");
      }

      // 3. Open UI
      _razorpay.open(options);

      // 4. Wait for completion
      return _checkoutCompleter!.future;

    } catch (e) {
      _setLoading(false);
      
      // 🔥 FIX: Extract the actual error message from the exception
      // If it's a DioError, we get the backend's "One order is pending" message
      String rawError = e.toString().replaceAll('Exception:', '').trim();
      
      _error = rawError; 
      debugPrint("❌ Place Order Error: $e");
      
      // We rethrow so the UI (CheckoutScreen) can catch it and show the SnackBar/Dialog
      rethrow; 
    }
  }

  /* ================================================= */
  /* HANDLERS                                          */
  /* ================================================= */

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      debugPrint("✅ Razorpay Success: ${response.paymentId}");
      
      if (_currentInternalPaymentId == null) {
        throw Exception("Session state lost. Please check My Orders.");
      }

      await CheckoutApi.confirmPayment(
        paymentId: _currentInternalPaymentId!,
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId ?? "", 
        razorpaySignature: response.signature ?? "",
      );

      await CartController.instance.load();
      
      if (_currentInternalOrderId != null) {
          final order = await CheckoutApi.getOrder(_currentInternalOrderId!);
          _checkoutCompleter?.complete(order);
      } else {
          _checkoutCompleter?.complete(null); 
      }

      _setLoading(false);

    } catch (e) {
      debugPrint("❌ Verification Error: $e");
      _setLoading(false);
      _error = "Payment successful but verification failed.";
      _checkoutCompleter?.completeError(e);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Razorpay Error: ${response.code} - ${response.message}");
    _setLoading(false);
    
    String msg = "Payment Failed";
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      msg = "Payment Cancelled";
    } else if (response.message != null) {
      msg = response.message!;
    }
    
    _error = msg;
    _checkoutCompleter?.completeError(Exception(msg));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("⚠️ Wallet Selected: ${response.walletName}");
    _setLoading(false);
    _checkoutCompleter?.completeError(Exception("External Wallet not supported"));
  }
}