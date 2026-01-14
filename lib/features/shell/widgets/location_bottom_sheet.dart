import 'package:flutter/material.dart';

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

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  late Future<List<SavedAddress>> _future;
  bool _locationServiceOn = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _future = SavedAddressStorage.getAll();
    _locationServiceOn =
        await LocationHelper.canUseLocationSilently();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        height: height * 0.6,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AnimatedBuilder(
          animation: LocationDetectingListenable(),
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHandle(),
                const SizedBox(height: 24),

                // =============================================
                // 🔄 FETCHING LOCATION
                // =============================================
                if (LocationState.isDetecting)
                  const LocationFetchingTile()

                // =============================================
                // 🔴 LOCATION PERMISSION OFF (CENTERED)
                // =============================================
                else if (!_locationServiceOn)
                  Expanded(
                    child: Center(
                      child: LocationPermissionOffTile(
                        onEnable: widget.onUseCurrentLocation,
                      ),
                    ),
                  )

                // =============================================
                // 🟢 LOCATION ON → NORMAL FLOW
                // =============================================
                else ...[
                  CurrentLocationTile(
                    isDetecting: false,
                    onTap: widget.onUseCurrentLocation,
                  ),

                  const SizedBox(height: 24),
                  const SectionTitle(text: 'Saved addresses'),
                  const SizedBox(height: 12),

                  SavedAddressList(
                    future: _future,
                    onSelect: widget.onSelectSavedAddress,
                  ),

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
                      setState(() {
                        _future =
                            SavedAddressStorage.getAll();
                      });
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.search,
                          color: Color(0xFF03B602),
                        ),
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
            );
          },
        ),
      ),
    );
  }
}

/// --------------------------------------------------
/// LISTENABLE
/// --------------------------------------------------
class LocationDetectingListenable extends ChangeNotifier {
  LocationDetectingListenable() {
    _tick();
  }

  void _tick() async {
    bool last = LocationState.isDetecting;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (LocationState.isDetecting != last) {
        last = LocationState.isDetecting;
        notifyListeners();
      }
    }
  }
}
