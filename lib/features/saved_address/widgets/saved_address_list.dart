import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Optional: for date formatting

import '../models/saved_address.model.dart';
import '../state/saved_address_controller.dart';
import '../screens/add_edit_address_screen.dart'; // Import for navigation

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

    if (ctrl.isLoading && ctrl.addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _green),
        ),
      );
    }

    /* ================================================= */
    /* ERROR                                             */
    /* ================================================= */

    if (ctrl.hasError && ctrl.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                ctrl.error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => ctrl.load(forceRefresh: true),
                child: const Text('Try Again'),
              )
            ],
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
        physics: const BouncingScrollPhysics(),
        child: Column(children: children),
      );
    }

    /// ⭐ profile screen → scroll list
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
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

    return Container(
      decoration: BoxDecoration(
        color: isActive ? _green.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? _green.withOpacity(0.5) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildLeadingIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.displayLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isActive ? _green : Colors.black87,
                              ),
                            ),
                          ),
                          if (address.type != SavedAddressType.other) ...[
                            const SizedBox(width: 6),
                            _buildTypeTag(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.address, // Correctly mapped to addressText
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrailingAction(context, ctrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? _green.withOpacity(0.1) : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForType(address.type),
        size: 20,
        color: isActive ? _green : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildTypeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        address.type.toApi(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildTrailingAction(BuildContext context, SavedAddressController ctrl) {
    if (showActions) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
        padding: EdgeInsets.zero,
        onSelected: (v) async {
          if (v == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditAddressScreen(address: address),
              ),
            );
          } else if (v == 'delete') {
            final ok = await _confirmDelete(context);
            if (ok == true) ctrl.delete(address.id);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      );
    } else if (isActive) {
      return const Icon(Icons.check_circle, color: _green, size: 24);
    } else if (onTap != null) {
      return Icon(Icons.chevron_right, color: Colors.grey.shade400);
    }
    return const SizedBox.shrink();
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete address?'),
        content: const Text(
          'This address will be removed from your saved locations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
      return Icons.home_rounded;
    case SavedAddressType.work:
      return Icons.work_rounded;
    case SavedAddressType.other:
      return Icons.location_on_rounded;
  }
}