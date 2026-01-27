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
  @override
  void initState() {
    super.initState();

    /// load once
    Future.microtask(
      () => context.read<SavedAddressController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),

      /* ================================================= */
      /* LIST                                               */
      /* ================================================= */

      body: const SavedAddressList(
        showActions: true, // delete enabled
      ),

      /* ================================================= */
      /* ADD BUTTON                                         */
      /* ================================================= */

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddEditAddressScreen(),
            ),
          );

          /// refresh after coming back
          if (context.mounted) {
            context
                .read<SavedAddressController>()
                .refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
