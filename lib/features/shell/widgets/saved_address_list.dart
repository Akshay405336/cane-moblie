import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';
import '../../../utils/location_state.dart';
import '../../../utils/saved_address.dart';
import 'location_tiles.dart';

class SavedAddressList extends StatelessWidget {
  final Future<List<SavedAddress>> future;

  /// ⭐ CLEANER → pass whole model
  final void Function(SavedAddress address) onSelect;

  const SavedAddressList({
    Key? key,
    required this.future,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔐 not logged in
    if (!AuthState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<SavedAddress>>(
      future: future,
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // error
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

        // empty
        if (list.isEmpty) {
          return const EmptySavedAddress();
        }

        // list
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final address = list[index];

            final isActive =
                LocationState.isSavedAddress &&
                    LocationState.activeSavedAddressId ==
                        address.id;

            return AddressTile(
              icon: iconForType(address.type),
              title: address.label,
              subtitle: address.address,
              isActive: isActive,

              /// ⭐ MUCH CLEANER
              onTap: () => onSelect(address),
            );
          },
        );
      },
    );
  }
}
