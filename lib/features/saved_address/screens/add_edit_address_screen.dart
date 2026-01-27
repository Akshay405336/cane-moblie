import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/saved_address.model.dart';
import '../state/saved_address_controller.dart';

class AddEditAddressScreen extends StatefulWidget {
  final SavedAddress? address;

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  bool get isEdit => address != null;

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState
    extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _labelCtrl;
  late TextEditingController _addressCtrl;

  SavedAddressType _type = SavedAddressType.home;

  @override
  void initState() {
    super.initState();

    _labelCtrl =
        TextEditingController(text: widget.address?.label);

    _addressCtrl =
        TextEditingController(text: widget.address?.address);

    _type = widget.address?.type ?? SavedAddressType.home;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /* ================================================= */
  /* SAVE                                               */
  /* ================================================= */

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<SavedAddressController>();

    final model = SavedAddress(
      id: widget.address?.id ?? const Uuid().v4(),
      customerId: widget.address?.customerId ?? '',
      label: _labelCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      type: _type,
    );

    if (widget.isEdit) {
      await ctrl.update(model);
    } else {
      await ctrl.create(model);
    }

    if (mounted) Navigator.pop(context);
  }

  /* ================================================= */
  /* UI                                                 */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEdit ? 'Edit Address' : 'Add Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /* LABEL */
              TextFormField(
                controller: _labelCtrl,
                decoration:
                    const InputDecoration(labelText: 'Label'),
                validator: (v) =>
                    v == null || v.length < 2
                        ? 'Enter label'
                        : null,
              ),

              const SizedBox(height: 16),

              /* ADDRESS */
              TextFormField(
                controller: _addressCtrl,
                decoration:
                    const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Enter address'
                        : null,
              ),

              const SizedBox(height: 16),

              /* TYPE */
              DropdownButtonFormField<SavedAddressType>(
                value: _type,
                items: SavedAddressType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration:
                    const InputDecoration(labelText: 'Type'),
              ),

              const Spacer(),

              /* SAVE BUTTON */
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
