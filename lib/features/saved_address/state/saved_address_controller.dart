import 'package:flutter/material.dart';

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

  List<SavedAddress> get addresses => _addresses;

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get error => _error;

  bool get isEmpty => _addresses.isEmpty;

  bool get isLoggedIn => true; // 🔥 later connect to AuthController

  /* ================================================= */
  /* LOAD                                              */
  /* ================================================= */

  Future<void> load({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses =
          await SavedAddressRepository.getAll(
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      _error = 'Failed to load saved addresses';
    }

    _isLoading = false;
    notifyListeners();
  }

  /* ================================================= */
  /* REFRESH                                           */
  /* ================================================= */

  Future<void> refresh() async {
    await load(forceRefresh: true);
  }

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  Future<void> create(SavedAddress address) async {
    try {
      final created =
          await SavedAddressRepository.create(address);

      _addresses = [..._addresses, created];

      notifyListeners();
    } catch (e) {
      _error = 'Unable to create address';
      notifyListeners();
    }
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  Future<void> update(SavedAddress address) async {
    try {
      final updated =
          await SavedAddressRepository.update(address);

      _addresses = _addresses
          .map((e) => e.id == updated.id ? updated : e)
          .toList();

      notifyListeners();
    } catch (e) {
      _error = 'Unable to update address';
      notifyListeners();
    }
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  Future<void> delete(String id) async {
    try {
      await SavedAddressRepository.delete(id);

      _addresses =
          _addresses.where((e) => e.id != id).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Unable to delete address';
      notifyListeners();
    }
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
}
