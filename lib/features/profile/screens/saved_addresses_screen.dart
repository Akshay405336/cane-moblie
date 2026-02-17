import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/widgets/saved_address_list.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';
import '../../saved_address/models/saved_address.model.dart';

// --- STYLE CONSTANTS ---
const kPrimaryColor = Color(0xFF2E7D32);
const kBgColor = Color(0xFFF8FAFB);

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> with SingleTickerProviderStateMixin {
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
        builder: (_) => AddEditAddressScreen(address: address),
      ),
    );

    if (mounted) {
      context.read<SavedAddressController>().refresh();
    }
  }

  /* ================================================= */
  /* UI COMPONENTS                                     */
  /* ================================================= */

  // Premium Shimmer Effect for Loading
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kBgColor, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 12, decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 10, decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SavedAddressController>();
    // We only show the full loader if we have NO data yet. 
    // If we have data, we let the list stay visible and just show the FAB loader.
    final bool showFullLoader = ctrl.isLoading && ctrl.addresses.isEmpty;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            fontSize: 19,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        shape: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, kBgColor],
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showFullLoader 
                ? _buildSkeletonLoader() 
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () => ctrl.refresh(),
                      child: SavedAddressList(
                        showActions: true,
                        onSelect: (addr) => _edit(addr),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: FloatingActionButton.extended(
          onPressed: _add,
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          splashColor: Colors.white24,
          elevation: 6,
          highlightElevation: 2,
          // Show a spinner in the FAB if refreshing but list is already visible
          icon: ctrl.isLoading && ctrl.addresses.isNotEmpty
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.add_location_alt_rounded, size: 22),
          label: Text(
            ctrl.isLoading && ctrl.addresses.isNotEmpty ? 'REFRESHING...' : 'ADD NEW ADDRESS',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 14,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}