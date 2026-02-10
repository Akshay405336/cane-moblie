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
  // We use this if the backend doesn't send a key.
  // =========================================================
  static const String _fallbackKey = "rzp_test_RbAfDB5uwpOElJ"; 

  late Razorpay _razorpay;
  Completer<Order?>? _checkoutCompleter;
  
  // Track session IDs
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
  /* 🔥 PLACE ORDER (With Fallback Logic)              */
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

      // 2. Prepare Data (Handle missing backend fields)
      
      // A. Key: Use backend key if available, else use your hardcoded key
      String rzpKey = data['key'] ?? _fallbackKey;
      
      // B. Amount: Use backend amount, else calculate (GrandTotal * 100 paise)
      int amount = data['amount'] ?? (value!.grandTotal * 100).toInt();

      var options = {
        'key': rzpKey,
        'amount': amount,
        'name': 'Cane & Tender',
        'description': 'Fresh Juice Order',
        'timeout': 30, 
        'prefill': {
          'contact': '9876543210', // You can fetch user phone here
          'email': 'customer@example.com'
        }
      };

      // C. Order ID: Only add if backend sent it. 
      // If missing, Razorpay runs in "Standard Mode" (works for testing).
      if (data['razorpayOrderId'] != null && data['razorpayOrderId'].toString().isNotEmpty) {
        options['order_id'] = data['razorpayOrderId'];
      } else {
        debugPrint("⚠️ WARNING: No Razorpay Order ID from server. Running in Standard Mode.");
      }

      // 3. Open UI
      _razorpay.open(options);

      // 4. Wait for completion
      return _checkoutCompleter!.future;

    } catch (e) {
      _setLoading(false);
      _error = "Could not initiate payment. Please try again.";
      debugPrint("❌ Place Order Error: $e");
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

      // 5. Verify with Backend
      await CheckoutApi.confirmPayment(
        paymentId: _currentInternalPaymentId!,
        razorpayPaymentId: response.paymentId!,
        // Handle nulls if running in Standard Mode (no order ID)
        razorpayOrderId: response.orderId ?? "", 
        razorpaySignature: response.signature ?? "",
      );

      // 6. Refresh Cart
      await CartController.instance.load();
      
      // 7. Get Final Order
      if (_currentInternalOrderId != null) {
         final order = await CheckoutApi.getOrder(_currentInternalOrderId!);
         _checkoutCompleter?.complete(order);
      } else {
         // Fallback if ID missing
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
    
    // Friendly error messages
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