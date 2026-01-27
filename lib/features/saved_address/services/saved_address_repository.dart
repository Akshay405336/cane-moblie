import 'package:flutter/foundation.dart';

import '../models/saved_address.model.dart';
import 'saved_address_api.dart';

class SavedAddressRepository {
  SavedAddressRepository._();

  /* ================================================= */
  /* CACHE                                             */
  /* ================================================= */

  static List<SavedAddress> _cache = [];

  /// never expose mutable list
  static List<SavedAddress> get cached =>
      List.unmodifiable(_cache);

  /* ================================================= */
  /* GET ALL                                           */
  /* ================================================= */

  static Future<List<SavedAddress>> getAll({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache.isNotEmpty) {
        debugPrint('📦 repo.getAll → from cache (${_cache.length})');
        return cached;
      }

      debugPrint('🌐 repo.getAll → fetching from API');

      final list = await SavedAddressApi.getAll();

      _cache = list.where((e) => !e.isDeleted).toList();

      debugPrint('✅ repo.getAll → fetched ${_cache.length}');

      return cached;
    } catch (e) {
      debugPrint('❌ repo.getAll → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* GET BY ID                                         */
  /* ================================================= */

  static Future<SavedAddress?> getById(String id) async {
    try {
      debugPrint('📡 repo.getById → $id');

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
    try {
      debugPrint('📡 repo.create');

      final created = await SavedAddressApi.create(address);

      if (!created.isDeleted) {
        _cache = [..._cache, created];
      }

      debugPrint('✅ repo.create → ${created.id}');

      return created;
    } catch (e) {
      debugPrint('❌ repo.create → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* UPDATE                                            */
  /* ================================================= */

  static Future<SavedAddress> update(
    SavedAddress address,
  ) async {
    try {
      debugPrint('📡 repo.update → ${address.id}');

      final updated = await SavedAddressApi.update(address);

      _cache = _cache
          .map((e) => e.id == updated.id ? updated : e)
          .where((e) => !e.isDeleted)
          .toList();

      debugPrint('✅ repo.update → done');

      return updated;
    } catch (e) {
      debugPrint('❌ repo.update → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* DELETE                                            */
  /* ================================================= */

  static Future<void> delete(String id) async {
    try {
      debugPrint('📡 repo.delete → $id');

      await SavedAddressApi.delete(id);

      _cache = _cache.where((e) => e.id != id).toList();

      debugPrint('✅ repo.delete → removed');
    } catch (e) {
      debugPrint('❌ repo.delete → $e');
      rethrow;
    }
  }

  /* ================================================= */
  /* CLEAR CACHE                                       */
  /* ================================================= */

  static void clearCache() {
    debugPrint('🗑 repo.clearCache');
    _cache = [];
  }
}
