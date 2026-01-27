import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';
import '../models/saved_address.model.dart';
import '../services/saved_address_repository.dart';

class SavedAddressController extends ChangeNotifier {
  /* ================================================= */
  /* STATE                                             */
  /* ================================================= */

  List<SavedAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;

  /* ================================================= */
  /* GETTERS                                           */
  /* ================================================= */

  /// never expose mutable list
  List<SavedAddress> get addresses =>
      List.unmodifiable(_addresses);

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get error => _error;

  bool get isEmpty => _addresses.isEmpty;

  /// ⭐ REAL AUTH CHECK
  bool get isLoggedIn => AuthState.isAuthenticated;

  /* ================================================= */
  /* LOAD                                              */
  /* ================================================= */

  Future<void> load({bool forceRefresh = false}) async {
    debugPrint('📡 SavedCtrl.load (refresh=$forceRefresh)');

    /// ⭐ guest → skip completely (NO API CALL)
    if (!isLoggedIn) {
      debugPrint('⛔ Guest user → skip saved addresses');
      _addresses = [];
      _error = null;
      notifyListeners();
      return;
    }

    _startLoading();

    try {
      _addresses =
          await SavedAddressRepository.getAll(
        forceRefresh: forceRefresh,
      );

      debugPrint('✅ Loaded ${_addresses.length} addresses');
    } catch (e) {
      debugPrint('❌ load error → $e');
      _error = 'Failed to load saved addresses';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* REFRESH                                           */
  /* ================================================= */

  Future<void> refresh() => load(forceRefresh: true);

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  Future<void> create(SavedAddress address) async {
    _startLoading();

    try {
      final created =
          await SavedAddressRepository.create(address);

      _addresses = [..._addresses, created];

      debugPrint('✅ created → ${created.id}');
    } catch (e) {
      debugPrint('❌ create error → $e');
      _error = 'Unable to create address';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  Future<void> update(SavedAddress address) async {
    _startLoading();

    try {
      final updated =
          await SavedAddressRepository.update(address);

      _addresses = _addresses
          .map((e) => e.id == updated.id ? updated : e)
          .toList();

      debugPrint('✅ updated → ${updated.id}');
    } catch (e) {
      debugPrint('❌ update error → $e');
      _error = 'Unable to update address';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  Future<void> delete(String id) async {
    _startLoading();

    try {
      await SavedAddressRepository.delete(id);

      _addresses =
          _addresses.where((e) => e.id != id).toList();

      debugPrint('✅ deleted → $id');
    } catch (e) {
      debugPrint('❌ delete error → $e');
      _error = 'Unable to delete address';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* CLEAR (logout helper) ⭐ VERY IMPORTANT            */
  /* ================================================= */

  void clear() {
    debugPrint('🧹 SavedCtrl.clear');

    _addresses = [];
    _error = null;
    _isLoading = false;

    /// ⭐ clear repo cache too (prevents old user leak)
    SavedAddressRepository.clearCache();

    notifyListeners();
  }

  /* ================================================= */
  /* HELPERS                                           */
  /* ================================================= */

  SavedAddress? findById(String id) {
    try {
      return _addresses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /* ================================================= */
  /* INTERNAL                                          */
  /* ================================================= */

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}
