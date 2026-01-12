import 'package:flutter/material.dart';

import '../../../utils/location_state.dart';
import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../location/screens/add_address_screen.dart';
import 'location_tiles.dart';

class SavedAddressList extends StatelessWidget {
  final Future<List<SavedAddress>> future;
  final void Function({
    required String id,
    required String address,
  }) onSelect;
  final VoidCallback onRefresh;

  const SavedAddressList({
    Key? key,
    required this.future,
    required this.onSelect,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SavedAddress>>(
      future: future,
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];

        if (list.isEmpty) {
          return const EmptySavedAddress();
        }

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final address = list[index];

            final isActive =
                LocationState.isSavedAddress &&
                LocationState.activeSavedAddressId == address.id;

            return AddressTile(
              icon: iconForType(address.type),
              title: address.label,
              subtitle: address.address,
              isActive: isActive,
              onTap: () {
                onSelect(
                  id: address.id,
                  address: address.address,
                );
              },
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddAddressScreen(existing: address),
                  ),
                );
                onRefresh();
              },
              onDelete: () async {
                await SavedAddressStorage.delete(address.id);

                // 🔐 IMPORTANT:
                // Do NOT auto-select any remaining address
                // User must choose explicitly
                onRefresh();
              },
            );
          },
        );
      },
    );
  }
}
