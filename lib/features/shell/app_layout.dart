import 'package:flutter/material.dart';

import '../home/screens/home_screen.dart';
import '../cart/screens/cart_page.dart';
import '../reorder/screens/reorder_page.dart';
import '../store/screens/store_page.dart';
import '../explore/screens/explore_page.dart';

import '../../utils/location_state.dart';
import '../../utils/location_helper.dart';

import 'widgets/app_header.dart';
import 'widgets/app_navbottom.dart';
import 'widgets/location_bottom_sheet.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  bool _sheetOpen = false;
  bool _initialized = false;
  bool _locationAskedThisSession = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  /* =============================================================== */
  /* INIT                                                             */
  /* =============================================================== */

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🟢 AppLayout started');

      /// Load persisted (for quick UI only)
      await LocationState.load();

      LocationHeaderController.instance.sync();

      /// ⭐ ALWAYS fetch fresh GPS on launch
      await _fetchAndSaveLocation();

      await _enforceLocationOnFreshLaunch();

      _initialized = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* =============================================================== */
  /* ENFORCE LOCATION ON FIRST LAUNCH                                */
  /* =============================================================== */

  Future<void> _enforceLocationOnFreshLaunch() async {
    if (_locationAskedThisSession) return;

    _locationAskedThisSession = true;

    final gpsEnabled = await LocationHelper.isGpsEnabled();

    debugPrint('🔍 Fresh launch GPS enabled = $gpsEnabled');

    if (!gpsEnabled) {
      _openLocationSheet();
    }
  }

  /* =============================================================== */
  /* USE CURRENT LOCATION (BUTTON TAP)                               */
  /* =============================================================== */
  /* ⭐ ALWAYS FETCH FRESH GPS HERE                                   */
  /* =============================================================== */

  Future<void> _useCurrentLocation() async {
    debugPrint('👉 Use current location tapped');

    final hasPermission =
        await LocationHelper.requestPermissionFromUser();

    if (!hasPermission) {
      LocationState.setError('Location permission required');
      LocationHeaderController.instance.sync();
      return;
    }

    final enabled =
        await LocationHelper.ensureLocationServiceEnabled();

    if (!enabled) return;

    /// ⭐ ALWAYS fetch fresh location
    await _fetchAndSaveLocation();
  }

  /* =============================================================== */
  /* ⭐ FETCH + SAVE GPS LOCATION (CORE LOGIC)                        */
  /* =============================================================== */

  Future<void> _fetchAndSaveLocation() async {
    debugPrint('🟡 Fetching GPS location...');

    LocationState.startDetecting();
    LocationHeaderController.instance.sync();

    final data =
        await LocationHelper.fetchCurrentLocationData();

    if (data == null) {
      debugPrint('❌ GPS fetch failed');

      LocationState.setError('Unable to detect location');
      LocationHeaderController.instance.sync();
      return;
    }

    debugPrint(
      '📍 GPS RESULT => '
      'lat=${data.latitude}, '
      'lng=${data.longitude}, '
      'address="${data.address}"',
    );

    await LocationState.setGpsAddress(
      address: data.address,
      lat: data.latitude,
      lng: data.longitude,
    );

    LocationHeaderController.instance.sync();

    debugPrint('✅ Location saved to state');

    if (_sheetOpen && mounted) {
      Navigator.pop(context);
    }
  }

  /* =============================================================== */
  /* OPEN BOTTOM SHEET                                               */
  /* =============================================================== */

  void _openLocationSheet() {
    if (_sheetOpen || !mounted) return;

    _sheetOpen = true;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return LocationBottomSheet(
          onUseCurrentLocation: _useCurrentLocation,

          onSelectSavedAddress: ({
            required String id,
            required String address,
            double? lat,
            double? lng,
          }) async {
            await LocationState.setSavedAddress(
              id: id,
              address: address,
              lat: lat,
              lng: lng,
            );

            LocationHeaderController.instance.sync();

            if (mounted) Navigator.pop(context);
          },
        );
      },
    ).whenComplete(() {
      _sheetOpen = false;
    });
  }

  /* =============================================================== */
  /* LIFECYCLE                                                        */
  /* =============================================================== */
  /* ⭐ ALWAYS REFRESH GPS ON RESUME                                   */
  /* =============================================================== */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    debugPrint('🔁 App resumed');

    final gpsEnabled = await LocationHelper.isGpsEnabled();

    if (gpsEnabled) {
      await _fetchAndSaveLocation();
    }
  }

  /* =============================================================== */
  /* UI                                                               */
  /* =============================================================== */

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        onAuthChanged: () => setState(() {}),
        onLocationTap: _openLocationSheet,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppNavBottom(
        currentIndex: _currentIndex,
        onTap: (index) =>
            setState(() => _currentIndex = index),
      ),
    );
  }
}
