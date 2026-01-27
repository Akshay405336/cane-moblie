import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/saved_address_controller.dart';
import '../widgets/saved_address_list.dart';
import 'add_edit_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  /* ================================================= */
  /* INIT                                               */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    /// ⭐ safer than microtask
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedAddressController>().load();
    });
  }

  /* ================================================= */
  /* UI                                                 */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SavedAddressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),

      /* ================================================= */
      /* LIST                                               */
      /* ================================================= */

      body: ctrl.isEmpty && !ctrl.isLoading
          ? _EmptyState(onAdd: _openAdd)
          : const SavedAddressList(
              showActions: true, // delete enabled
            ),

      /* ================================================= */
      /* ADD BUTTON                                         */
      /* ================================================= */

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  /* ================================================= */
  /* NAVIGATION                                         */
  /* ================================================= */

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditAddressScreen(),
      ),
    );

    /// ⭐ usually NOT required because controller updates cache
    /// but keep if you want server re-sync
    // context.read<SavedAddressController>().refresh();
  }
}

/* ===================================================== */
/* EMPTY STATE (better UX)                               */
/* ===================================================== */

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 54,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          const Text(
            'No saved addresses yet',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAdd,
            child: const Text('Add your first address'),
          ),
        ],
      ),
    );
  }
}
