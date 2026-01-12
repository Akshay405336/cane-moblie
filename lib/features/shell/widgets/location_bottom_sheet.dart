import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/location_state.dart';
import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../location/screens/add_address_screen.dart';

class LocationBottomSheet extends StatefulWidget {
  final Future<void> Function() onUseCurrentLocation;
  final void Function({
    required String id,
    required String address,
  }) onSelectSavedAddress;

  const LocationBottomSheet({
    Key? key,
    required this.onUseCurrentLocation,
    required this.onSelectSavedAddress,
  }) : super(key: key);

  @override
  State<LocationBottomSheet> createState() =>
      _LocationBottomSheetState();
}

class _LocationBottomSheetState
    extends State<LocationBottomSheet> {
  late Future<List<SavedAddress>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = SavedAddressStorage.getAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDetecting = LocationState.isDetecting;
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.6,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FFF8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(),
          const SizedBox(height: 16),

          _title(),
          const SizedBox(height: 20),

          // 📍 CURRENT LOCATION
          CurrentLocationTile(
            isDetecting: isDetecting,
            onTap: widget.onUseCurrentLocation,
          ),

          const SizedBox(height: 24),
          _sectionTitle('Saved addresses'),
          const SizedBox(height: 12),

          // 📦 SAVED ADDRESS LIST
          Expanded(
            child: FutureBuilder<List<SavedAddress>>(
              future: _future,
              builder: (context, snapshot) {
                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return const _EmptySavedAddress();
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final address = list[index];

                    return AddressTile(
                      icon: _iconForType(address.type),
                      title: address.label,
                      subtitle: address.address,
                      onTap: () {
                        widget.onSelectSavedAddress(
                          id: address.id,
                          address: address.address,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 12),

          AddNewAddressTile(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAddressScreen(),
                ),
              );

              // 🔄 refresh list after return
              setState(_load);
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.green.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      'Select delivery address',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1B5E20),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF689F38),
      ),
    );
  }

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
}

// ===============================================================
// EMPTY STATE
// ===============================================================

class _EmptySavedAddress extends StatelessWidget {
  const _EmptySavedAddress();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Text(
        'No saved addresses yet',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ===============================================================
// USE CURRENT LOCATION
// ===============================================================

class CurrentLocationTile extends StatelessWidget {
  final bool isDetecting;
  final VoidCallback onTap;

  const CurrentLocationTile({
    Key? key,
    required this.isDetecting,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isDetecting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location,
                color: Color(0xFF2E7D32)),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Use current location',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enable GPS for accurate delivery',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF558B2F),
                    ),
                  ),
                ],
              ),
            ),

            isDetecting
                ? _shimmer()
                : const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF558B2F),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ===============================================================
// SAVED ADDRESS TILE
// ===============================================================

class AddressTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AddressTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0F2F1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF81C784)),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF33691E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ADD NEW ADDRESS
// ===============================================================

class AddNewAddressTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewAddressTile({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: const [
            Icon(Icons.add, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text(
              'Add new address',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
