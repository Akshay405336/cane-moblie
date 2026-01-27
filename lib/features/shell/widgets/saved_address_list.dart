import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/models/saved_address.model.dart';

import '../../shell/widgets/location_tiles.dart';

class SavedAddressList extends StatelessWidget {
  final void Function(SavedAddress address) onSelect;

  /// parent controls which is active
  final String? activeSavedId;

  const SavedAddressList({
    super.key,
    required this.onSelect,
    this.activeSavedId,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<SavedAddressController, _SavedViewState>(
      selector: (_, c) => _SavedViewState(
        isLoggedIn: c.isLoggedIn,
        isLoading: c.isLoading,
        addresses: c.addresses,
      ),
      builder: (_, state, __) {
        /* ================================================= */
        /* NOT LOGGED IN                                     */
        /* ================================================= */

        if (!state.isLoggedIn) {
          return const SizedBox.shrink();
        }

        /* ================================================= */
        /* LOADING                                           */
        /* ================================================= */

        if (state.isLoading) {
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

        if (state.addresses.isEmpty) {
          return const EmptySavedAddress();
        }

        /* ================================================= */
        /* LIST (Column > ListView for bottom sheet perf)     */
        /* ================================================= */

        return Column(
          children: [
            for (final address in state.addresses) ...[
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
      },
    );
  }
}

/* ===================================================== */
/* SMALL OPTIMIZED VIEW MODEL (reduces rebuild noise)     */
/* ===================================================== */

class _SavedViewState {
  final bool isLoggedIn;
  final bool isLoading;
  final List<SavedAddress> addresses;

  _SavedViewState({
    required this.isLoggedIn,
    required this.isLoading,
    required this.addresses,
  });
}
