import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address.model.dart';
import '../state/saved_address_controller.dart';
import '../widgets/address_field_picker.dart';

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

  bool _saving = false;

  double? _lat;
  double? _lng;

  /* ================================================= */
  /* INIT                                               */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    _labelCtrl =
        TextEditingController(text: widget.address?.label);

    _addressCtrl =
        TextEditingController(text: widget.address?.address);

    _type = widget.address?.type ?? SavedAddressType.home;

    /// ⭐ prefill coords when editing
    _lat = widget.address?.lat;
    _lng = widget.address?.lng;
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

    /// must pick location
    if (_lat == null || _lng == null) {
      _showError('Please select location on map');
      return;
    }

    setState(() => _saving = true);

    final ctrl = context.read<SavedAddressController>();

    try {
      final model = SavedAddress(
        id: widget.address?.id ?? '',
        customerId: widget.address?.customerId ?? '',

        label: _labelCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        type: _type,

        /// ⭐ direct coords (no geocoding)
        lat: _lat!,
        lng: _lng!,
      );

      if (widget.isEdit) {
        await ctrl.update(model);
      } else {
        await ctrl.create(model);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ================================================= */
  /* ERROR                                              */
  /* ================================================= */

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
                    v == null || v.trim().length < 2
                        ? 'Minimum 2 characters'
                        : null,
              ),

              const SizedBox(height: 16),

              /* ================================================= */
              /* ⭐ MAP PICKER FIELD (reusable widget)               */
              /* ================================================= */

              AddressFieldPicker(
                controller: _addressCtrl,
                lat: _lat,
                lng: _lng,
                onPicked: (lat, lng) {
                  _lat = lat;
                  _lng = lng;
                },
              ),

              const SizedBox(height: 16),

              /* TYPE */
              DropdownButtonFormField<SavedAddressType>(
                value: _type,
                items: SavedAddressType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.displayName),
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
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
