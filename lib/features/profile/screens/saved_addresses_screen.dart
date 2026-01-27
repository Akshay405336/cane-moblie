import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/widgets/saved_address_list.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();

    /// load once when page opens
    Future.microtask(
      () =>
          context.read<SavedAddressController>().load(),
    );
  }

  /* ================================================= */
  /* ADD NEW ADDRESS                                   */
  /* ================================================= */

  Future<void> _add() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditAddressScreen(),
      ),
    );

    /// refresh after returning
    if (mounted) {
      context.read<SavedAddressController>().refresh();
    }
  }

  /* ================================================= */
  /* EDIT ADDRESS                                      */
  /* ================================================= */

  Future<void> _edit(address) async {
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
      /* BODY                                               */
      /* ================================================= */

      body: SafeArea(
        child: SavedAddressList(
          showActions: true, // enables delete menu

          /// tap → edit
          onSelect: (addr) => _edit(addr),
        ),
      ),

      /* ================================================= */
      /* ADD BUTTON                                         */
      /* ================================================= */

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),

      /* ================================================= */
      /* LOADING OVERLAY                                    */
      /* ================================================= */

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }
}
