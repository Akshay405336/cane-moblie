import 'package:flutter/material.dart';
import '../screens/map_picker_screen.dart';

class AddressFieldPicker extends StatelessWidget {
  final TextEditingController controller;
  final double? lat;
  final double? lng;
  final Function(double lat, double lng) onPicked;

  const AddressFieldPicker({
    super.key,
    required this.controller,
    required this.onPicked,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Address',
        suffixIcon: Icon(Icons.location_on),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? 'Select address' : null,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapPickerScreen(
              lat: lat,
              lng: lng,
            ),
          ),
        );

        if (result != null) {
          controller.text = result["address"];
          onPicked(result["lat"], result["lng"]);
        }
      },
    );
  }
}
