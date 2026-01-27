import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address.model.dart';
import '../state/saved_address_controller.dart';

const _green = Color(0xFF03B602);

class SavedAddressList extends StatelessWidget {
  /// bottom sheet select
  final void Function(SavedAddress address)? onSelect;

  /// profile screen actions
  final bool showActions;

  /// highlight active
  final String? activeSavedId;

  const SavedAddressList({
    super.key,
    this.onSelect,
    this.showActions = false,
    this.activeSavedId,
  });

  bool get _isSelectionMode => onSelect != null;

  @override
  Widget build(BuildContext context) {
    /// ⭐ SIMPLE + SAFE (no Selector bugs)
    final ctrl = context.watch<SavedAddressController>();

    /* ================================================= */
    /* LOADING                                           */
    /* ================================================= */

    if (ctrl.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    /* ================================================= */
    /* ERROR                                             */
    /* ================================================= */

    if (ctrl.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            ctrl.error ?? 'Something went wrong',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    /* ================================================= */
    /* EMPTY                                             */
    /* ================================================= */

    if (ctrl.addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No saved addresses yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    /* ================================================= */
    /* LIST                                              */
    /* ================================================= */

    final children = [
      for (final address in ctrl.addresses) ...[
        _AddressCard(
          address: address,
          isActive: activeSavedId == address.id,
          showActions: showActions,
          onTap: _isSelectionMode ? () => onSelect!(address) : null,
        ),
        const SizedBox(height: 10),
      ],
    ];

    /// ⭐ bottom sheet → scroll safe
    if (_isSelectionMode) {
      return SingleChildScrollView(
        child: Column(children: children),
      );
    }

    /// ⭐ profile screen → scroll list
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }
}

/* ===================================================== */
/* ADDRESS CARD                                          */
/* ===================================================== */

class _AddressCard extends StatelessWidget {
  final SavedAddress address;
  final bool isActive;
  final bool showActions;
  final VoidCallback? onTap;

  const _AddressCard({
    required this.address,
    required this.isActive,
    required this.showActions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<SavedAddressController>();

    return Material(
      color: isActive ? _green.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                _iconForType(address.type),
                color: isActive ? _green : Colors.grey,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isActive ? _green : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (showActions)
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'delete') {
                      final ok = await _confirmDelete(context);
                      if (ok == true) ctrl.delete(address.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                )
              else if (isActive)
                const Icon(Icons.check_circle, color: _green)
              else if (onTap != null)
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete address?'),
        content: const Text(
          'This address will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================================================== */

IconData _iconForType(SavedAddressType type) {
  switch (type) {
    case SavedAddressType.home:
      return Icons.home_outlined;
    case SavedAddressType.work:
      return Icons.work_outline;
    case SavedAddressType.other:
      return Icons.location_on_outlined;
  }
}
