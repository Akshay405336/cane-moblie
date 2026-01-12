import 'dart:convert';
import 'secure_storage.dart';
import 'saved_address.dart';
import 'location_state.dart';

class SavedAddressStorage {
  static const _key = 'saved_addresses';

  // --------------------------------------------------
  // READ
  // --------------------------------------------------

  static Future<List<SavedAddress>> getAll() async {
    final raw = await SecureStorage.read(_key);
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => SavedAddress.fromJson(e))
        .toList();
  }

  // --------------------------------------------------
  // SAVE / UPSERT
  // --------------------------------------------------

  static Future<void> save(SavedAddress address) async {
    final list = await getAll();

    // Home & Work → replace existing
    if (address.type != SavedAddressType.other) {
      list.removeWhere((a) => a.type == address.type);
    }

    list.add(address);
    await _persist(list);
  }

  // --------------------------------------------------
  // UPDATE (EDIT ADDRESS)
  // --------------------------------------------------

  static Future<void> update(SavedAddress updated) async {
    final list = await getAll();

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
    final list = await getAll();
    list.removeWhere((a) => a.id == id);
    await _persist(list);

    // 🔐 IMPORTANT:
    // If deleted address was active → clear location
    if (LocationState.activeSavedAddressId == id) {
      await LocationState.clearSavedAddress();
    }
  }

  // --------------------------------------------------
  // INTERNAL
  // --------------------------------------------------

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
