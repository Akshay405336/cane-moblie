import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';
import '../models/saved_address.model.dart';
import '../services/saved_address_repository.dart';
import '../../location/state/location_controller.dart';

class SavedAddressController extends ChangeNotifier {

  /* ================================================= */
  /* ⭐ LOCATION DEPENDENCY (INJECTED FROM PROVIDER)    */
  /* ================================================= */

  LocationController? _locationCtrl;

  SavedAddressController([this._locationCtrl]);

  /// ⭐ REQUIRED for ProxyProvider
  void setLocationController(LocationController ctrl) {
    _locationCtrl = ctrl;
  }

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

    /// ⭐ guest → clear instantly
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
      final created = await SavedAddressRepository.create(address);

      // ⭐ SYNC LOGIC: If we created a HOME/WORK, remove the old one from the list
      // because the backend only allows one active of each type.
      if (created.type == SavedAddressType.home || created.type == SavedAddressType.work) {
         _addresses = _addresses.where((e) => e.type != created.type).toList();
      }

      // Add new one to the top
      _addresses = [created, ..._addresses];

      debugPrint('✅ Created → ${created.id}');
    } catch (e) {
      debugPrint('❌ Create error → $e');
      
      // ⭐ BACKEND ERROR MAPPING
      if (e.toString().contains('SAVED_ADDRESS_TYPE_ALREADY_EXISTS')) {
        _error = 'An active ${address.type.displayName} address already exists';
      } else {
        _error = 'Unable to create address';
      }
      
      rethrow; // Rethrow so the UI (AddEditScreen) can catch it and show the snackbar
    } finally {
      _stopLoading();
    }
  }

  /* ================================================= */
  /* UPDATE ⭐ HEADER SYNC FIX                          */
  /* ================================================= */

  Future<void> update(SavedAddress address) async {
    _startLoading();

    try {
      final updated = await SavedAddressRepository.update(address);

      /* ---------------- update list ---------------- */

      _addresses = _addresses
          .map((e) => e.id == updated.id ? updated : e)
          .toList();

      debugPrint('✅ Updated → ${updated.id}');

      /* ================================================= */
      /* ⭐ THIS IS THE IMPORTANT PART                      */
      /* If currently selected address was edited → update  */
      /* header location + outlet socket automatically      */
      /* ================================================= */

      final current = _locationCtrl?.current;

      if (current != null &&
          current.savedAddressId == updated.id) {

        debugPrint('🔄 Syncing updated address to header');

        await _locationCtrl?.setSaved(
          updated.toLocationData(),
        );
      }

    } catch (e) {
      debugPrint('❌ Update error → $e');
      _error = 'Unable to update address';
      rethrow;
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

  /// Helper to check if a type already exists for the UI
  bool hasAddressType(SavedAddressType type) {
    if (type == SavedAddressType.other) return false;
    return _addresses.any((e) => e.type == type);
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