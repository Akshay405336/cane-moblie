import 'package:flutter/material.dart';

import '../../../utils/auth_state.dart';
import '../../../utils/location_helper.dart';
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
    double? lat,
    double? lng,
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

class _LocationBottomSheetState extends State<LocationBottomSheet>
    with WidgetsBindingObserver {
  late Future<List<SavedAddress>> _future;

  // ⭐ ONLY service state (not permission)
  bool _gpsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* ================================================= */
  /* LOAD DATA                                         */
  /* ================================================= */

  Future<void> _load() async {
    _future = SavedAddressStorage.getAll();

    // ⭐ ONLY check GPS service
    _gpsEnabled = await LocationHelper.isGpsEnabled();

    if (mounted) setState(() {});
  }

  /* ================================================= */
  /* RESUME FROM SETTINGS                              */
  /* ================================================= */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    final enabled = await LocationHelper.isGpsEnabled();

    if (mounted) {
      setState(() {
        _gpsEnabled = enabled;
      });
    }

    // close sheet automatically if turned ON
    if (enabled && mounted) {
      Navigator.pop(context);
    }
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.6,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 24),

          /// 🔄 Detecting
          if (LocationState.isDetecting)
            const LocationFetchingTile()

          else ...[
            /// 🔴 GPS OFF
            if (!_gpsEnabled)
              LocationPermissionOffTile(
                onEnable: widget.onUseCurrentLocation,
              ),

            /// 🟢 GPS ON
            if (_gpsEnabled)
              CurrentLocationTile(
                isDetecting: false,
                onTap: widget.onUseCurrentLocation,
              ),

            /// SAVED ADDRESSES
            if (AuthState.isAuthenticated) ...[
              const SizedBox(height: 24),
              const SectionTitle(text: 'Saved addresses'),
              const SizedBox(height: 12),

              SavedAddressList(
                future: _future,
                onSelect: (addr) {
                  widget.onSelectSavedAddress(
                    id: addr.id,
                    address: addr.address,
                    lat: addr.lat,
                    lng: addr.lng,
                  );
                },
              ),
            ],

            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 12),

            /// SEARCH MANUALLY
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddAddressScreen(),
                  ),
                );

                _load();
              },
              child: Row(
                children: const [
                  Icon(Icons.search, color: Color(0xFF03B602)),
                  SizedBox(width: 8),
                  Text(
                    'Search manually',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF03B602),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
