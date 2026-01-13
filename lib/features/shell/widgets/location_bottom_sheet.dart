import 'package:flutter/material.dart';

import '../../../utils/location_state.dart';
import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../location/screens/add_address_screen.dart';
import 'saved_address_list.dart';
import 'location_tiles.dart';

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
    _reload();
  }

  void _reload() {
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 16),
          const BottomSheetTitle(),

          const SizedBox(height: 20),
          CurrentLocationTile(
            isDetecting: isDetecting,
            onTap: widget.onUseCurrentLocation,
          ),

          const SizedBox(height: 24),
          const SectionTitle(text: 'Saved addresses'),
          const SizedBox(height: 12),

          // ---------------- SAVED ADDRESSES ----------------
          Expanded(
            child: SavedAddressList(
              future: _future,
              onSelect: widget.onSelectSavedAddress,
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 12),

          // ---------------- ADD NEW ADDRESS ----------------
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAddressScreen(),
                ),
              );

              // Refresh after returning
              setState(_reload);
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: const [
                Icon(Icons.add, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Add new address',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
