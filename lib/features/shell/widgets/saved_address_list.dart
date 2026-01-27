import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/models/saved_address.model.dart';
import '../../shell/widgets/location_tiles.dart';

class SavedAddressList extends StatelessWidget {
  final void Function(SavedAddress address) onSelect;
  final String? activeSavedId;

  const SavedAddressList({
    super.key,
    required this.onSelect,
    this.activeSavedId,
  });

  @override
  Widget build(BuildContext context) {
    /// ⭐ SIMPLE + RELIABLE
    final ctrl = context.watch<SavedAddressController>();

    /* ================================================= */
    /* NOT LOGGED IN                                     */
    /* ================================================= */

    if (!ctrl.isLoggedIn) {
      return const SizedBox.shrink();
    }

    /* ================================================= */
    /* LOADING                                           */
    /* ================================================= */

    if (ctrl.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    /* ================================================= */
    /* EMPTY                                             */
    /* ================================================= */

    if (ctrl.addresses.isEmpty) {
      return const EmptySavedAddress();
    }

    /* ================================================= */
    /* LIST                                              */
    /* ================================================= */

    return Column(
      children: [
        for (final address in ctrl.addresses) ...[
          AddressTile(
            icon: iconForType(address.type),
            title: address.label,
            subtitle: address.address,
            isActive: activeSavedId == address.id,
            onTap: () => onSelect(address),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
