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
  bool _locationServiceOn = true;

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

  Future<void> _load() async {
    _future = SavedAddressStorage.getAll();
    _locationServiceOn =
        await LocationHelper.canUseLocationSilently();
    if (mounted) setState(() {});
  }

  /// ✅ Auto close sheet when returning from settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    final enabled =
        await LocationHelper.canUseLocationSilently();

    if (enabled && mounted) {
      Navigator.pop(context);
    }
  }

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
      child: AnimatedBuilder(
        animation: LocationStateNotifier.instance,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHandle(),
              const SizedBox(height: 24),

              /// 🔄 Detecting GPS
              if (LocationState.isDetecting)
                const LocationFetchingTile()

              else ...[
                /// 🔴 LOCATION OFF → SHOW ENABLE + OTHERS
                if (!_locationServiceOn)
                  LocationPermissionOffTile(
                    onEnable: widget.onUseCurrentLocation,
                  ),

                /// 🟢 LOCATION ON → USE CURRENT LOCATION
                if (_locationServiceOn) ...[
                  CurrentLocationTile(
                    isDetecting: false,
                    onTap: widget.onUseCurrentLocation,
                  ),
                ],

                /// SAVED ADDRESSES (ONLY LOGGED IN)
                if (AuthState.isAuthenticated) ...[
                  const SizedBox(height: 24),
                  const SectionTitle(text: 'Saved addresses'),
                  const SizedBox(height: 12),
                  SavedAddressList(
                    future: _future,
                    onSelect: widget.onSelectSavedAddress,
                  ),
                ],

                const Spacer(),
                const Divider(height: 1),
                const SizedBox(height: 12),

                /// SEARCH MANUALLY (ALWAYS AVAILABLE)
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
    );
  }
}

/// --------------------------------------------------
/// CLEAN NOTIFIER (NO INFINITE LOOP)
/// --------------------------------------------------
class LocationStateNotifier extends ChangeNotifier {
  LocationStateNotifier._() {
    _sync();
  }

  static final instance = LocationStateNotifier._();

  bool _last = LocationState.isDetecting;

  void _sync() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (_last != LocationState.isDetecting) {
        _last = LocationState.isDetecting;
        notifyListeners();
      }
    }
  }
}
