import 'package:flutter/material.dart';
import '../models/checkout_summary.model.dart';
import '../services/checkout_api.dart';
import '../../orders/models/order.model.dart';
import '../../cart/state/cart_controller.dart';

class CheckoutController extends ValueNotifier<CheckoutSummary?> {
  CheckoutController._() : super(null);
  static final instance = CheckoutController._();

  bool _loading = false;
  String? _error;
  String? _outletId;

  bool get isLoading => _loading;
  String? get error => _error;

  /* ================================================= */
  /* OUTLET CONTEXT (🔥 REQUIRED)                      */
  /* ================================================= */

  void setOutlet(String outletId) {
    _outletId = outletId;
  }

  void _ensureOutlet() {
    if (_outletId == null) {
      throw Exception('OutletId not set in CheckoutController');
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /* ================================================= */
  /* LOAD SUMMARY                                     */
  /* ================================================= */

  Future<void> loadSummary(String addressId) async {
    // 🔥 AUTO-SYNC outlet from cart if missing
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

  /* ================================================= */
  /* CHANGE ADDRESS                                   */
  /* ================================================= */

  Future<void> changeAddress(String newAddressId) async {
    await loadSummary(newAddressId);
  }

  /* ================================================= */
  /* PLACE ORDER                                      */
  /* ================================================= */

  Future<Order?> placeOrder() async {
    if (value == null) return null;

    // 🔥 FINAL GUARANTEE
    _outletId ??= CartController.instance.value.outletId;
    _ensureOutlet();

    _setLoading(true);

    try {
      // 1. Start checkout
      final ids = await CheckoutApi.startCheckout(
        outletId: _outletId!,
        addressId: value!.addressId,
      );

      // 2. Confirm payment (mock)
      await CheckoutApi.confirmPayment(ids['paymentId']!);

      // 3. Reload cart
      await CartController.instance.load();

      // 4. Fetch order
      return await CheckoutApi.getOrder(ids['orderId']!);
    } catch (e) {
      _error = "Order placement failed. Please try again.";
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
