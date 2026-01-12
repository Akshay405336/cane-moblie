import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../../utils/location_state.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _controller = TextEditingController();
  SavedAddressType _type = SavedAddressType.home;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);

    final address = SavedAddress(
      id: const Uuid().v4(),
      type: _type,
      label: _labelForType(_type),
      address: text,
    );

    await SavedAddressStorage.save(address);

    await LocationState.setSavedAddress(
      id: address.id,
      address: address.address,
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save address as',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _typeSelector(),

            const SizedBox(height: 24),
            const Text(
              'Address',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
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
                    : const Text('Save address'),
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
