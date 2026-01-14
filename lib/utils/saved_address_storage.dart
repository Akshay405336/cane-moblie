import 'dart:convert';

import 'secure_storage.dart';
import 'saved_address.dart';
import 'location_state.dart';
import '../features/location/services/saved_address_api.dart';
import 'auth_state.dart';

class SavedAddressStorage {
  static const _key = 'saved_addresses';

  // --------------------------------------------------
  // READ (BACKEND → CACHE → RETURN)
  // --------------------------------------------------

  static Future<List<SavedAddress>> getAll() async {
    // 👤 Guest → LOCAL ONLY (never touch backend)
    if (!AuthState.isAuthenticated) {
      return _getLocal();
    }

    try {
      final remote = await SavedAddressApi.getAll();

      final list = remote.map<SavedAddress>((e) {
        final typeString =
            e['type']?.toString().toLowerCase();

        final resolvedType =
            SavedAddressType.values.firstWhere(
          (t) => t.name == typeString,
          orElse: () => SavedAddressType.other,
        );

        return SavedAddress(
          id: e['id']?.toString() ?? '',
          type: resolvedType,
          label: e['label']?.toString() ?? '',
          address: e['addressText']?.toString() ?? '',
        );
      }).where((a) => a.id.isNotEmpty).toList();

      // 💾 Cache backend result
      await _persist(list);
      return list;
    } catch (_) {
      // 🔐 Backend failed → fallback to local cache
      return _getLocal();
    }
  }

  // --------------------------------------------------
  // CREATE
  // --------------------------------------------------

  static Future<void> save(SavedAddress address) async {
    if (!AuthState.isAuthenticated) return;

    final data = await SavedAddressApi.create(
      type: address.type.name,
      label: address.label,
      addressText: address.address,
    );

    if (data == null) return;

    final saved = SavedAddress(
      id: data['id']?.toString() ?? '',
      type: address.type,
      label: address.label,
      address: address.address,
    );

    if (saved.id.isEmpty) return;

    final list = await _getLocal();

    // 🔐 Only one HOME / WORK allowed
    if (saved.type != SavedAddressType.other) {
      list.removeWhere((a) => a.type == saved.type);
    }

    list.add(saved);
    await _persist(list);
  }

  // --------------------------------------------------
  // UPDATE
  // --------------------------------------------------

  static Future<void> update(SavedAddress updated) async {
  if (!AuthState.isAuthenticated) return;

  final data = await SavedAddressApi.update(
    id: updated.id,
    addressText: updated.address,
  );

  // ✅ update() returns Map<String, dynamic>?
  if (data == null) return;

  final list = await _getLocal();
  final index = list.indexWhere((a) => a.id == updated.id);
  if (index == -1) return;

  list[index] = updated;
  await _persist(list);
}


  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  static Future<void> delete(String id) async {
    if (!AuthState.isAuthenticated) return;

    final success = await SavedAddressApi.delete(id);
    if (!success) return;

    final list = await _getLocal();
    list.removeWhere((a) => a.id == id);
    await _persist(list);

    // ⚠️ If deleted address was active → clear ONLY saved source
    if (LocationState.activeSavedAddressId == id) {
      await LocationState.removeActiveSavedAddress();
    }
  }

  // --------------------------------------------------
  // LOCAL HELPERS
  // --------------------------------------------------

  static Future<List<SavedAddress>> _getLocal() async {
    final raw = await SecureStorage.read(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List decoded = jsonDecode(raw);
      return decoded
          .map((e) => SavedAddress.fromJson(e))
          .toList();
    } catch (_) {
      // 🔐 Corrupted cache → reset
      await SecureStorage.delete(_key);
      return [];
    }
  }

  static Future<void> _persist(
    List<SavedAddress> list,
  ) async {
    final encoded = jsonEncode(
      list.map((e) => e.toJson()).toList(),
    );
    await SecureStorage.write(_key, encoded);
  }

  // --------------------------------------------------
  // CLEAR (DEBUG / FULL RESET ONLY)
  // --------------------------------------------------

  static Future<void> clearAll() async {
    await SecureStorage.delete(_key);
  }
}
