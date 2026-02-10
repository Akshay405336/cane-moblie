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
        actions: [
          // Extra: Refresh button in AppBar for convenience
          IconButton(
            onPressed: () => ctrl.load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      /* ================================================= */
      /* LIST / BODY                                        */
      /* ================================================= */

      body: Stack(
        children: [
          // Main Content with RefreshIndicator
          RefreshIndicator(
            onRefresh: () => ctrl.load(),
            child: ctrl.isEmpty && !ctrl.isLoading
                ? _EmptyState(onAdd: _openAdd)
                : const SavedAddressList(
                    showActions: true, // delete enabled
                  ),
          ),

          // Extra: Global Loading Overlay
          if (ctrl.isLoading && ctrl.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
            
          // Extra: Error indicator if fetch fails (Optional check)
          if (ctrl.hasError && !ctrl.isLoading)
             Center(
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.error_outline, color: Colors.red, size: 48),
                   const SizedBox(height: 16),
                   const Text('Could not load addresses'),
                   TextButton(
                     onPressed: () => ctrl.load(),
                     child: const Text('Retry'),
                   )
                 ],
               ),
             ),
        ],
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

    /// ⭐ Refresh after returning to ensure UI matches backend state
    /// specifically helpful after "SAVED_ADDRESS_CREATED"
    if (mounted) {
       context.read<SavedAddressController>().load();
    }
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
    return ListView( // Changed to ListView so RefreshIndicator works
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No saved addresses yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your home, work or other frequently\nused locations for quicker checkouts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add your first address'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}