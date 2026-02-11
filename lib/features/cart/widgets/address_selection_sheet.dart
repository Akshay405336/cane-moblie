import 'package:flutter/material.dart';
import '../../location/models/location.model.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';
import '../../saved_address/state/saved_address_controller.dart';

class AddressSelectionSheet extends StatelessWidget {
  final SavedAddressController addressCtrl;
  final Function(LocationData) onAddressSelected;

  const AddressSelectionSheet({
    super.key,
    required this.addressCtrl,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Colors.black87),
                  SizedBox(width: 8),
                  Text("Select Delivery Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: addressCtrl,
                builder: (context, __) {
                  if (addressCtrl.isLoading) return const Center(child: CircularProgressIndicator());
                  if (addressCtrl.addresses.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: addressCtrl.addresses.length,
                    itemBuilder: (context, index) {
                      final address = addressCtrl.addresses[index];
                      return _buildAddressItem(context, address);
                    },
                  );
                },
              ),
            ),
            _buildAddAddressButton(context),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.grey.shade400),
          const Text("No saved addresses yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, dynamic address) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onAddressSelected(address.toLocationData());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(address.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                        child: Text(address.type.displayName, style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(address.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editAddress(context, address),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Add New Address"),
          onPressed: () => _editAddress(context, null),
        ),
      ),
    );
  }

  Future<void> _editAddress(BuildContext context, dynamic address) async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
    );
    addressCtrl.load(forceRefresh: true);
  }
}