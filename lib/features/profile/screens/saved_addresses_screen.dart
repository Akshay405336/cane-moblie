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
      // ✅ Enhanced: Modern grey background matches other screens
      backgroundColor: const Color(0xFFF5F6F8),
      
      // ✅ Enhanced: Clean White AppBar
      appBar: AppBar(
        title: const Text(
          'Saved Addresses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      /* ================================================= */
      /* BODY                                              */
      /* ================================================= */

      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              // ✅ Enhanced: Top spacing for better separation
              padding: const EdgeInsets.only(top: 12),
              child: SavedAddressList(
                showActions: true,

                /// tap → edit
                onSelect: (addr) => _edit(addr),
              ),
            ),
          ),

          /* ================================================= */
          /* ⭐ LOADING OVERLAY (nice UX)                      */
          /* ================================================= */

          if (ctrl.isLoading)
            ColoredBox(
              color: Colors.black.withOpacity(0.2), // ✅ Enhanced: Smoother overlay
              child: const Center(
                child: CircularProgressIndicator(
                  // ✅ Enhanced: Brand Green Color
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),

      /* ================================================= */
      /* ADD BUTTON                                        */
      /* ================================================= */

      floatingActionButton: FloatingActionButton.extended(
        onPressed: ctrl.isLoading ? null : _add,
        // ✅ Enhanced: Brand styling
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Address',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        elevation: 4,
      ),
    );
  }
}