import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../location/services/location_service.dart';
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

  bool _saving = false;

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

    setState(() => _saving = true);

    final ctrl = context.read<SavedAddressController>();

    try {
      /* --------------------------------------------- */
      /* ⭐ 1. GEOCODE TEXT → LAT/LNG                   */
      /* --------------------------------------------- */

      final geo = await LocationService.geocodeAddress(
        _addressCtrl.text.trim(),
      );

      if (geo == null || !geo.hasCoordinates) {
        _showError('Unable to detect coordinates for address');
        return;
      }

      /* --------------------------------------------- */
      /* ⭐ 2. BUILD MODEL                              */
      /* --------------------------------------------- */

      final model = SavedAddress(
        /// ⭐ DO NOT create id for new
        id: widget.address?.id ?? '',
        customerId: widget.address?.customerId ?? '',

        label: _labelCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        type: _type,

        lat: geo.latitude,
        lng: geo.longitude,
      );

      /* --------------------------------------------- */
      /* ⭐ 3. SAVE                                     */
      /* --------------------------------------------- */

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

              /* ADDRESS */
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    v == null || v.trim().isEmpty
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
