import 'package:flutter/material.dart';

import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../../utils/location_state.dart';

class AddAddressScreen extends StatefulWidget {
  final SavedAddress? existing;

  const AddAddressScreen({
    Key? key,
    this.existing,
  }) : super(key: key);

  @override
  State<AddAddressScreen> createState() =>
      _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _controller = TextEditingController();
  SavedAddressType _type = SavedAddressType.home;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      _controller.text = widget.existing!.address;
      _type = widget.existing!.type;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =================================================
  // SAVE / UPDATE
  // =================================================

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);

    if (_isEdit) {
      // -------- UPDATE --------
      final updated = widget.existing!.copyWith(
        address: text,
      );

      await SavedAddressStorage.update(updated);

      if (LocationState.activeSavedAddressId ==
          updated.id) {
        await LocationState.setSavedAddress(
          id: updated.id,
          address: updated.address,
        );
      }
    } else {
      // -------- CREATE --------
      final temp = SavedAddress(
        id: '', // backend assigns
        type: _type,
        label: _labelForType(_type),
        address: text,
      );

      await SavedAddressStorage.save(temp);

      // ✅ Deterministic selection
      final list = await SavedAddressStorage.getAll();
      final created = list.firstWhere(
        (a) => a.type == _type,
        orElse: () => list.last,
      );

      await LocationState.setSavedAddress(
        id: created.id,
        address: created.address,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  // =================================================
  // DELETE
  // =================================================

  Future<void> _delete() async {
    if (!_isEdit) return;

    final id = widget.existing!.id;
    await SavedAddressStorage.delete(id);

    // Active address cleanup already handled,
    // this just makes intent explicit
    if (mounted) Navigator.pop(context);
  }

  String _labelForType(SavedAddressType type) {
    switch (type) {
      case SavedAddressType.home:
        return 'Home';
      case SavedAddressType.work:
        return 'Work';
      case SavedAddressType.other:
        return 'Other';
    }
  }

  // =================================================
  // UI
  // =================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit address' : 'Add address'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save address as',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            IgnorePointer(
              ignoring: _isEdit,
              child: _typeSelector(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter full address',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : Text(
                        _isEdit
                            ? 'Update address'
                            : 'Save address',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    return Row(
      children: SavedAddressType.values.map((type) {
        final selected = _type == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_labelForType(type)),
              selected: selected,
              onSelected: (_) {
                setState(() => _type = type);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
