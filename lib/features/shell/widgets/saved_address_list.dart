import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';
import '../../../utils/location_state.dart';
import '../../../utils/saved_address.dart';
import 'location_tiles.dart';

class SavedAddressList extends StatelessWidget {
  final Future<List<SavedAddress>> future;
  final void Function({
    required String id,
    required String address,
  }) onSelect;

  const SavedAddressList({
    Key? key,
    required this.future,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------
    // 🔐 NOT LOGGED IN → SHOW NOTHING
    // --------------------------------------------------
    if (!AuthState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    // --------------------------------------------------
    // LOGGED-IN FLOW
    // --------------------------------------------------
    return FutureBuilder<List<SavedAddress>>(
      future: future,
      builder: (context, snapshot) {
        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // ERROR
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Unable to load saved addresses',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          );
        }

        final list = snapshot.data ?? [];

        // EMPTY
        if (list.isEmpty) {
          return const EmptySavedAddress();
        }

        // LIST
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
            );
          },
        );
      },
    );
  }
}
