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
    // 👤 Guest → no backend
    if (!AuthState.isAuthenticated) {
      return _getLocal();
    }

    // 🔄 Fetch from backend
    final remote = await SavedAddressApi.getAll();

    final list = remote.map((e) {
      return SavedAddress(
        id: e['id'],
        type: SavedAddressType.values.firstWhere(
          (t) => t.name.toUpperCase() == e['type'],
        ),
        label: e['label'],
        address: e['addressText'],
      );
    }).toList();

    // 💾 Cache locally
    await _persist(list);
    return list;
  }

  // --------------------------------------------------
  // SAVE / UPSERT
  // --------------------------------------------------

  static Future<void> save(SavedAddress address) async {
    final data = await SavedAddressApi.create(
      type: address.type.name,
      label: address.label,
      addressText: address.address,
    );

    if (data == null) return;

    final saved = SavedAddress(
      id: data['id'],
      type: address.type,
      label: address.label,
      address: address.address,
    );

    final list = await _getLocal();

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
    final data = await SavedAddressApi.update(
      id: updated.id,
      addressText: updated.address,
    );

    if (data == null) return;

    final list = await _getLocal();
    final index =
        list.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    list[index] = updated;
    await _persist(list);
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  static Future<void> delete(String id) async {
    final success = await SavedAddressApi.delete(id);
    if (!success) return;

    final list = await _getLocal();
    list.removeWhere((a) => a.id == id);
    await _persist(list);

    if (LocationState.activeSavedAddressId == id) {
      await LocationState.clearSavedAddress();
    }
  }

  // --------------------------------------------------
  // LOCAL HELPERS
  // --------------------------------------------------

  static Future<List<SavedAddress>> _getLocal() async {
    final raw = await SecureStorage.read(_key);
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => SavedAddress.fromJson(e))
        .toList();
  }

  static Future<void> _persist(
    List<SavedAddress> list,
  ) async {
    final encoded =
        jsonEncode(list.map((e) => e.toJson()).toList());
    await SecureStorage.write(_key, encoded);
  }

  static Future<void> clear() async {
    await SecureStorage.delete(_key);
  }
}
