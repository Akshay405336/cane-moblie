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

  bool get isLoading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /// Load checkout details for a specific address
  Future<void> loadSummary(String addressId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await CheckoutApi.getSummary(addressId);
      value = data;
    } catch (e) {
      _error = e.toString();
      debugPrint("Checkout Load Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Switch address (Just re-runs loadSummary)
  Future<void> changeAddress(String newAddressId) async {
    await loadSummary(newAddressId);
  }

  Future<Order?> placeOrder() async {
    if (value == null) return null;

    _setLoading(true);
    try {
      // 1. Start
      final ids = await CheckoutApi.startCheckout(value!.addressId);
      // 2. Pay (Mock)
      await CheckoutApi.confirmPayment(ids['paymentId']!);
      // 3. Clear Cart
      await CartController.instance.load();
      // 4. Get Order
      return await CheckoutApi.getOrder(ids['orderId']!);
    } catch (e) {
      _error = "Order placement failed. Please try again.";
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}