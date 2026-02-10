import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
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
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _labelCtrl;
  late TextEditingController _addressCtrl;

  late SavedAddressType _type;
  
  // State variables
  bool _saving = false;
  bool _formWasEdited = false; // To track "dirty" state
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _labelCtrl = TextEditingController(text: widget.address?.label);
    _addressCtrl = TextEditingController(text: widget.address?.address);
    _type = widget.address?.type ?? SavedAddressType.home;
    _lat = widget.address?.lat;
    _lng = widget.address?.lng;

    // Listen for changes to mark form as "dirty"
    _labelCtrl.addListener(_markAsEdited);
    _addressCtrl.addListener(_markAsEdited);
  }

  void _markAsEdited() {
    if (!_formWasEdited) {
      setState(() => _formWasEdited = true);
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ===========================================================================
  // LOGIC
  // ===========================================================================

  Future<void> _save() async {
    // Hide keyboard immediately
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact(); // Physical feedback on error
      return;
    }

    if (_lat == null || _lng == null) {
      _showError('Please select a location on the map');
      return;
    }

    setState(() => _saving = true);

    try {
      final ctrl = context.read<SavedAddressController>();
      
      final model = SavedAddress(
        id: widget.address?.id ?? '', 
        customerId: widget.address?.customerId ?? '',
        label: _labelCtrl.text.trim(),
        address: _addressCtrl.text.trim(), // Maps to addressText in backend
        type: _type,
        lat: _lat,
        lng: _lng,
      );

      if (widget.isEdit) {
        await ctrl.update(model);
      } else {
        await ctrl.create(model);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      }
    } catch (e) {
      // ⭐ UPDATED: Enhanced error handling for backend constraints
      String errorMsg = 'Failed to save address. Please try again.';
      
      // If your controller throws the specific backend error code
      final errorStr = e.toString();
      if (errorStr.contains('SAVED_ADDRESS_TYPE_ALREADY_EXISTS')) {
        errorMsg = 'An active ${_type.displayName} address already exists.';
      }

      if (mounted) {
        HapticFeedback.vibrate();
        _showError(errorMsg);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Intercepts back button to warn about unsaved changes
  Future<bool> _onWillPop() async {
    if (!_formWasEdited || _saving) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_formWasEdited || _saving, // Allow pop if not edited or currently saving (to prevent double-taps)
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Address' : 'New Address'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabelField(),
                        const SizedBox(height: 24),
                        _buildMapPicker(),
                        const SizedBox(height: 24),
                        _buildTypeDropdown(),
                        // Extra info note for HOME/WORK
                        if (_type != SavedAddressType.other)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Note: You can only have one active ${_type.displayName} address.',
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelCtrl,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Label (e.g., Friend Office, Granny Home)',
        hintText: 'Enter a name for this address',
        prefixIcon: Icon(Icons.label_outline),
        border: OutlineInputBorder(),
        filled: true,
      ),
      validator: (v) {
        if (v == null || v.trim().length < 2) return 'Please enter a valid label';
        return null;
      },
    );
  }

  Widget _buildMapPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADDRESS LOCATION',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AddressFieldPicker(
          controller: _addressCtrl,
          lat: _lat,
          lng: _lng,
          onPicked: (lat, lng) {
            setState(() {
              _lat = lat;
              _lng = lng;
            });
            _markAsEdited();
          },
        ),
        if (_lat == null && _formWasEdited)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Location is required',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<SavedAddressType>(
      value: _type,
      decoration: const InputDecoration(
        labelText: 'Address Type',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: SavedAddressType.values.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e.displayName),
        );
      }).toList(),
      onChanged: widget.isEdit ? null : (v) { // Backend constraint: usually better to let user pick type only on creation
        if (v != null) {
          setState(() => _type = v);
          _markAsEdited();
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _saving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(
                  widget.isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
        ),
      ),
    );
  }
}