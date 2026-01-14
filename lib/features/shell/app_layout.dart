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
  bool _checkedOnce = false;

  /// 🔐 NEW: tracks settings → resume auto-fetch
  bool _waitingForLocationEnable = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationState.load();
      await _enforceLocation();
      _checkedOnce = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ===============================================================
  // APP RESUME
  // ===============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    // 🔥 AUTO-FETCH after user enabled location
    if (_waitingForLocationEnable) {
      _waitingForLocationEnable = false;
      await _fetchAndSetLocation();
      return;
    }

    await _enforceLocation();
  }

  // ===============================================================
  // HARD LOCATION ENFORCEMENT
  // ===============================================================

  Future<void> _enforceLocation() async {
    if (!mounted || _sheetOpen) return;

    final hasService =
        await LocationHelper.canUseLocationSilently();

    final hasLocation = LocationState.hasPersistedLocation;

    if (!hasService || !hasLocation) {
      _openLocationSheet(force: true);
    }
  }

  // ===============================================================
  // BUTTON: USE CURRENT LOCATION
  // ===============================================================

  Future<void> _useCurrentLocation() async {
    final hasPermission =
        await LocationHelper.requestPermissionFromUser();

    if (!hasPermission) {
      LocationState.setError('Location permission required');
      setState(() {});
      return;
    }

    final serviceEnabled =
        await LocationHelper.ensureLocationServiceEnabled();

    // 🔐 User is going to settings → wait & auto-fetch
    if (!serviceEnabled) {
      _waitingForLocationEnable = true;
      return;
    }

    // Service already ON → fetch immediately
    await _fetchAndSetLocation();
  }

  // ===============================================================
  // FETCH + STORE LOCATION (ONE PLACE ONLY)
  // ===============================================================

  Future<void> _fetchAndSetLocation() async {
    LocationState.startDetecting();
    if (mounted) setState(() {});

    final address =
        await LocationHelper.fetchCurrentAddress();

    if (address.isEmpty) {
      LocationState.setError('Unable to detect location');
      if (mounted) setState(() {});
      return;
    }

    await LocationState.setGpsAddress(address);

    if (_sheetOpen && mounted) {
      Navigator.pop(context);
    }

    if (mounted) setState(() {});
  }

  // ===============================================================
  // OPEN LOCATION SHEET
  // ===============================================================

  void _openLocationSheet({bool force = false}) {
    if (_sheetOpen || !mounted) return;

    _sheetOpen = true;

    showModalBottomSheet(
      context: context,
      isDismissible: !force ? true : false,
      enableDrag: !force ? true : false,
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
          }) async {
            await LocationState.setSavedAddress(
              id: id,
              address: address,
            );

            if (mounted) {
              Navigator.pop(context);
            }

            setState(() {});
          },
        );
      },
    ).whenComplete(() async {
      _sheetOpen = false;
      if (mounted) await _enforceLocation();
    });
  }

  // ===============================================================
  // UI
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    // ⏳ Wait for first location check
    if (!_checkedOnce) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        onAuthChanged: () => setState(() {}),
        onLocationTap: () => _openLocationSheet(),
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
