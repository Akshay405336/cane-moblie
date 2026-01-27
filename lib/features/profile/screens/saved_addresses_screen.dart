import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/widgets/saved_address_list.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';
import '../../saved_address/models/saved_address.model.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    /// ⭐ load only if logged in
    Future.microtask(() {
      final ctrl = context.read<SavedAddressController>();

      if (ctrl.isLoggedIn) {
        ctrl.load();
      }
    });
  }

  /* ================================================= */
  /* ADD                                               */
  /* ================================================= */

  Future<void> _add() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditAddressScreen(),
      ),
    );

    if (mounted) {
      context.read<SavedAddressController>().refresh();
    }
  }

  /* ================================================= */
  /* EDIT                                              */
  /* ================================================= */

  Future<void> _edit(SavedAddress address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditAddressScreen(address: address),
      ),
    );

    if (mounted) {
      context.read<SavedAddressController>().refresh();
    }
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SavedAddressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),

      /* ================================================= */
      /* BODY                                               */
      /* ================================================= */

      body: Stack(
        children: [
          SafeArea(
            child: SavedAddressList(
              showActions: true,

              /// tap → edit
              onSelect: (addr) => _edit(addr),
            ),
          ),

          /* ================================================= */
          /* ⭐ LOADING OVERLAY (nice UX)                        */
          /* ================================================= */

          if (ctrl.isLoading)
            const ColoredBox(
              color: Color(0x22000000),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),

      /* ================================================= */
      /* ADD BUTTON                                         */
      /* ================================================= */

      floatingActionButton: FloatingActionButton.extended(
        onPressed: ctrl.isLoading ? null : _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
