import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/theme/home_colors.dart';
import '../../location/models/location.model.dart';
import '../../location/state/location_controller.dart';
import '../../saved_address/models/saved_address.model.dart';
import '../../saved_address/state/saved_address_controller.dart';
import '../state/checkout_controller.dart';

class AddressSelectorSheet extends StatefulWidget {
  const AddressSelectorSheet({super.key});

  @override
  State<AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<AddressSelectorSheet> {
  @override
  void initState() {
    super.initState();
    Provider.of<SavedAddressController>(context, listen: false).load();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SavedAddressController>(context);
    final addresses = controller.addresses;
    final isLoading = controller.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Select Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          if (isLoading)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
          else if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    const Text("No saved addresses found."),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Add Address page
                        },
                        child: const Text("Add New Address"))
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (ctx, i) {
                  final addr = addresses[i];
                  return ListTile(
                    leading: Icon(
                      _getIconForType(addr.type),
                      color: HomeColors.primaryGreen,
                    ),
                    title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(addr.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // 1. Update Checkout API
                      CheckoutController.instance.changeAddress(addr.id);

                      // 2. Update Global Location State
                      final newLocation = LocationData(
                        latitude: addr.lat,
                        longitude: addr.lng,
                        source: AddressSource.saved,
                        formattedAddress: addr.address,
                        savedAddressId: addr.id,
                      );
                      Provider.of<LocationController>(context, listen: false).setSaved(newLocation);

                      // 3. Close
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(SavedAddressType type) {
    switch (type) {
      case SavedAddressType.home:
        return Icons.home;
      case SavedAddressType.work:
        return Icons.work;
      case SavedAddressType.other:
        return Icons.location_on;
    }
  }
}