import 'package:flutter/material.dart';

import '../../../routes.dart';
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
    // GUEST FALLBACK
    // --------------------------------------------------
    if (!AuthState.isAuthenticated) {
      return const _GuestFallback();
    }

    // --------------------------------------------------
    // LOGGED-IN FLOW (DISPLAY ONLY)
    // --------------------------------------------------
    return FutureBuilder<List<SavedAddress>>(
      future: future,
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];

        // EMPTY
        if (list.isEmpty) {
          return const EmptySavedAddress();
        }

        // LIST
        return ListView.separated(
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

// =====================================================
// GUEST UI
// =====================================================

class _GuestFallback extends StatelessWidget {
  const _GuestFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Save addresses for faster checkout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Login to add and manage your saved addresses',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.login,
            );
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
