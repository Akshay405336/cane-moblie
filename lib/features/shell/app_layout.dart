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

  // 🔥 THIS IS THE MISSING PIECE
  bool _userRequestedLocation = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationState.load();
      await _ensureLocation(); // silent check
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🔄 Coming back from settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensureLocation(); // continue flow if user requested
    }
  }

  // ===============================================================
  // LOCATION FLOW (SINGLE SOURCE OF TRUTH)
  // ===============================================================

  Future<void> _ensureLocation({bool userTriggered = false}) async {
    // 🔑 remember user intent
    if (userTriggered) {
      _userRequestedLocation = true;
    }

    final shouldProceed = _userRequestedLocation;

    final ready = shouldProceed
        ? await LocationHelper.ensureLocationReady() // opens settings
        : await LocationHelper.isReadySilently();    // silent check

    // ❌ Still not ready → show sheet only
    if (!ready) {
      _openLocationSheet();
      return;
    }

    // ✅ READY → FETCH LOCATION
    try {
      LocationState.startDetecting();
      setState(() {});

      final address = await LocationHelper.fetchAddress();
      await LocationState.setAddress(address);

      LocationState.stopDetecting();
      _userRequestedLocation = false; // ✅ reset intent

      // Close sheet if open
      if (_sheetOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _sheetOpen = false;
      }

      setState(() {});
    } catch (_) {
      LocationState.stopDetecting();
      LocationState.setError('Unable to detect location');
      setState(() {});
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
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return LocationBottomSheet(
          onUseCurrentLocation: () async {
            await _ensureLocation(userTriggered: true);
          },
        );
      },
    ).then((_) {
      _sheetOpen = false;
    });
  }

  // ===============================================================
  // UI
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onAuthChanged: () => setState(() {}),
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
