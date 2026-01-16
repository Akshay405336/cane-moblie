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

  /// 🔐 Enforce location ONLY once per cold start
  static bool _enforcedThisSession = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  // ===============================================================
  // INIT (COLD START)
  // ===============================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationState.load();
      LocationHeaderController.instance.sync();

      await _enforceLocationIfNeeded();

      _initialized = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ===============================================================
  // LOCATION ENFORCEMENT (COLD START ONLY)
  // ===============================================================

  Future<void> _enforceLocationIfNeeded() async {
    if (_enforcedThisSession || !mounted) return;
    _enforcedThisSession = true;

    final hasStoredLocation =
        LocationState.hasPersistedLocation;

    final canUseLocation =
        await LocationHelper.canUseLocationSilently();

    /// Ask ONLY if:
    /// - fresh app open
    /// - no stored address
    /// - GPS OFF
    if (!hasStoredLocation && !canUseLocation) {
      _openLocationSheet();
    }
  }

  // ===============================================================
  // USE CURRENT LOCATION (BUTTON TAP)
  // ===============================================================

  Future<void> _useCurrentLocation() async {
    final hasPermission =
        await LocationHelper.requestPermissionFromUser();

    if (!hasPermission) {
      LocationState.setError('Location permission required');
      LocationHeaderController.instance.sync();
      return;
    }

    /// 🚨 IMPORTANT:
    /// Do NOT trust GPS state here
    /// Just open settings and wait for resume
    await LocationHelper.ensureLocationServiceEnabled();
  }

  // ===============================================================
  // FETCH + SAVE LOCATION
  // ===============================================================

  Future<void> _fetchAndSaveLocation() async {
    LocationState.startDetecting();
    LocationHeaderController.instance.sync();

    final address =
        await LocationHelper.fetchCurrentAddress();

    if (address.isEmpty) {
      LocationState.setError('Unable to detect location');
      LocationHeaderController.instance.sync();
      return;
    }

    await LocationState.setGpsAddress(address);
    LocationHeaderController.instance.sync();

    if (_sheetOpen && mounted) {
      Navigator.pop(context);
    }
  }

  // ===============================================================
  // OPEN LOCATION SHEET
  // ===============================================================

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

          /// SAVED ADDRESS SELECT
          onSelectSavedAddress: ({
            required String id,
            required String address,
          }) async {
            await LocationState.setSavedAddress(
              id: id,
              address: address,
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

  // ===============================================================
  // APP LIFECYCLE (THIS IS THE KEY FIX)
  // ===============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    /// Re-check GPS AFTER returning from system settings
    final gpsEnabled =
        await LocationHelper.canUseLocationSilently();

    if (gpsEnabled &&
        !LocationState.hasPersistedLocation) {
      await _fetchAndSaveLocation();
    }
  }

  // ===============================================================
  // UI
  // ===============================================================

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
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
