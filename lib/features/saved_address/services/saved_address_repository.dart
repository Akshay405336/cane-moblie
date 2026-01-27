import 'package:flutter/foundation.dart';

import '../models/saved_address.model.dart';
import 'saved_address_api.dart';

class SavedAddressRepository {
  SavedAddressRepository._();

  /* ================================================= */
  /* CACHE (optional but useful)                       */
  /* ================================================= */

  static List<SavedAddress> _cache = [];

  static List<SavedAddress> get cached => _cache;

  /* ================================================= */
  /* GET ALL                                           */
  /* ================================================= */

  static Future<List<SavedAddress>> getAll({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.isNotEmpty) {
      return _cache;
    }

    final list = await SavedAddressApi.getAll();

    // filter soft deleted
    _cache = list.where((e) => !e.isDeleted).toList();

    return _cache;
  }

  /* ================================================= */
  /* GET BY ID                                         */
  /* ================================================= */

  static Future<SavedAddress?> getById(String id) async {
    try {
      final address = await SavedAddressApi.getById(id);

      if (address.isDeleted) return null;

      return address;
    } catch (e) {
      debugPrint('❌ repo.getById → $e');
      return null;
    }
  }

  /* ================================================= */
  /* CREATE                                            */
  /* ================================================= */

  static Future<SavedAddress> create(
    SavedAddress address,
  ) async {
    final created = await SavedAddressApi.create(address);

    _cache = [..._cache, created];

    return created;
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  static Future<SavedAddress> update(
    SavedAddress address,
  ) async {
    final updated = await SavedAddressApi.update(address);

    _cache = _cache
        .map((e) => e.id == updated.id ? updated : e)
        .toList();

    return updated;
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  static Future<void> delete(String id) async {
    await SavedAddressApi.delete(id);

    _cache = _cache.where((e) => e.id != id).toList();
  }

  /* ================================================= */
  /* CLEAR CACHE                                       */
  /* ================================================= */

  static void clearCache() {
    _cache = [];
  }
}
