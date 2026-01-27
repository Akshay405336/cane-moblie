import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../location/state/location_controller.dart';
import '../../location/services/location_service.dart';
import '../../saved_address/state/saved_address_controller.dart';
import '../../saved_address/screens/add_edit_address_screen.dart';

import 'location_tiles.dart';
import '../../saved_address/widgets/saved_address_list.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet>
    with WidgetsBindingObserver {
  bool _gpsEnabled = true;

  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    debugPrint('📍 BottomSheet initState');

    WidgetsBinding.instance.addObserver(this);

    _checkGps();
  }

  @override
  void dispose() {
    debugPrint('📍 BottomSheet dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* ================================================= */
  /* GPS CHECK                                         */
  /* ================================================= */

  Future<void> _checkGps() async {
    debugPrint('🔍 Checking GPS...');

    final enabled = await LocationService.isGpsEnabled();

    debugPrint('📡 GPS enabled = $enabled');

    if (!mounted) return;

    setState(() => _gpsEnabled = enabled);
  }

  /* ================================================= */
  /* RETURN FROM SETTINGS                              */
  /* ================================================= */

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (state != AppLifecycleState.resumed) return;

  debugPrint('🔁 App resumed → rechecking GPS');

  await Future.delayed(const Duration(milliseconds: 400));
  await _checkGps();

  /// ⭐ JUST CLOSE SHEET (NO DETECT HERE)
  if (_gpsEnabled && mounted && Navigator.canPop(context)) {
    debugPrint('✅ GPS ON → closing sheet immediately');
    Navigator.pop(context);
  }
}


  /* ================================================= */
  /* BUILD                                             */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();
    final savedCtrl = context.watch<SavedAddressController>();

    debugPrint(
      '🟢 Sheet rebuild → gps=$_gpsEnabled | hasLocation=${location.hasLocation} | detecting=${location.isDetecting}',
    );

    /* ================================================= */
    /* AUTO CLOSE WHEN LOCATION AVAILABLE                */
    /* ================================================= */

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (location.hasLocation && Navigator.canPop(context)) {
        debugPrint('✅ Location ready → closing sheet');
        Navigator.pop(context);
      }
    });

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 20),
/* ================================================= */
/* ⭐ GPS / CURRENT LOCATION SECTION                  */
/* ================================================= */

if (!_gpsEnabled)
  LocationPermissionOffTile(
    onEnablePressed: () async {
      debugPrint('🚀 Enable tapped');

      final granted = await LocationService.requestPermission();
      if (!granted) {
        debugPrint('❌ Permission denied');
        return;
      }

      await LocationService.openSettings();
    },
  )
else if (location.isDetecting)
  const LocationFetchingTile()
else
  CurrentLocationTile(
    isDetecting: false,
    onTap: () {
      debugPrint('📍 Detect tapped');
      location.detectCurrentLocation();
    },
  ),

/* ================================================= */
/* ⭐ ALWAYS SHOW SAVED ADDRESSES IF LOGGED IN ⭐ */
/* ================================================= */

if (savedCtrl.isLoggedIn) ...[
  const SizedBox(height: 26),
  const SectionTitle(text: 'Saved addresses'),
  const SizedBox(height: 12),

  SavedAddressList(
    activeSavedId: location.current?.savedAddressId,
    onSelect: (addr) {
      debugPrint('🏠 Saved selected → ${addr.address}');
      location.setSaved(addr.toLocationData());
    },
  ),
],


            const Spacer(),
            const Divider(),
            const SizedBox(height: 12),

            /* ================================================= */
            /* MANUAL SEARCH                                      */
            /* ================================================= */
            InkWell(
              onTap: () async {
                debugPrint('🔎 Manual search tapped');

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressScreen(),
                  ),
                );

                savedCtrl.refresh();
              },
              child: const Row(
                children: [
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
        ),
      ),
    );
  }
}
