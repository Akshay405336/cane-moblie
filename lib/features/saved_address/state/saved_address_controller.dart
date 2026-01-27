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

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get error => _error;

  bool get isEmpty => _addresses.isEmpty;

  bool get isLoggedIn => AuthState.isAuthenticated;

  /* ================================================= */
  /* LOAD ⭐ MAIN ENTRY                                */
  /* ================================================= */

  Future<void> load({bool forceRefresh = false}) async {
    debugPrint('\n==============================');
    debugPrint('📡 SavedAddressController.load()');
    debugPrint('👉 isLoggedIn = $isLoggedIn');
    debugPrint('👉 forceRefresh = $forceRefresh');
    debugPrint('==============================');

    /// ⭐ if guest skip API completely
    if (!isLoggedIn) {
      debugPrint('⛔ Guest → clearing addresses');
      _addresses = [];
      _error = null;
      notifyListeners();
      return;
    }

    _startLoading();

    try {
      debugPrint('🚀 Calling repository.getAll()');

      final result = await SavedAddressRepository.getAll(
        forceRefresh: forceRefresh,
      );

      debugPrint('📦 RAW RESULT LENGTH => ${result.length}');
      debugPrint('📦 RAW RESULT => $result');

      _addresses = result;

      debugPrint('✅ STORED COUNT => ${_addresses.length}');
    } catch (e, s) {
      debugPrint('❌ LOAD ERROR → $e');
      debugPrint('$s');
      _error = 'Failed to load saved addresses';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* REFRESH                                           */
  /* ================================================= */

  Future<void> refresh() async {
    debugPrint('🔄 Manual refresh');
    await load(forceRefresh: true);
  }

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  Future<void> create(SavedAddress address) async {
    _startLoading();

    try {
      final created =
          await SavedAddressRepository.create(address);

      _addresses = [..._addresses, created];

      debugPrint('✅ Created → ${created.id}');
    } catch (e) {
      debugPrint('❌ Create error → $e');
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

      debugPrint('✅ Updated → ${updated.id}');
    } catch (e) {
      debugPrint('❌ Update error → $e');
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

      debugPrint('✅ Deleted → $id');
    } catch (e) {
      debugPrint('❌ Delete error → $e');
      _error = 'Unable to delete address';
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* CLEAR (logout helper)                             */
  /* ================================================= */

  void clear() {
    debugPrint('🧹 Controller cleared (logout)');

    _addresses = [];
    _error = null;
    _isLoading = false;

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
    debugPrint('⏳ Loading START');
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    debugPrint('✅ Loading END');
    _isLoading = false;
    notifyListeners();
  }
}
