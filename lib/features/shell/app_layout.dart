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

  /// 🔑 VERY IMPORTANT
  /// This flag exists ONLY in memory.
  /// - Fresh app launch → false
  /// - Background resume → stays true
  bool _locationAskedThisSession = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  // ===============================================================
  // INIT — THIS RUNS ON EVERY REAL APP LAUNCH
  // ===============================================================

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 AppLayout CREATED (new process)');

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🟢 PostFrameCallback start');

      // 1️⃣ Load persisted location (if any)
      await LocationState.load();
      debugPrint(
        '📍 Location loaded | hasPersisted=${LocationState.hasPersistedLocation}',
      );

      // 2️⃣ Sync header UI
      LocationHeaderController.instance.sync();
      debugPrint('🧠 Header synced');

      // 3️⃣ Enforce location rule (ONLY ON FRESH LAUNCH)
      await _enforceLocationOnFreshLaunch();

      _initialized = true;
      if (mounted) setState(() {});
      debugPrint('✅ AppLayout initialized');
    });
  }

  @override
  void dispose() {
    debugPrint('🔴 AppLayout.dispose (widget destroyed)');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ===============================================================
  // 🔐 LOCATION ENFORCEMENT — YOUR CUSTOM RULE
  // ===============================================================

  Future<void> _enforceLocationOnFreshLaunch() async {
    debugPrint(
      '🔍 enforceLocation | alreadyAsked=$_locationAskedThisSession',
    );

    // ❌ DO NOT ask again in same app session
    if (_locationAskedThisSession) {
      debugPrint('⛔ Location already asked in this session');
      return;
    }

    _locationAskedThisSession = true;

    final gpsEnabled =
        await LocationHelper.canUseLocationSilently();

    debugPrint(
      '📍 Fresh launch check | gpsEnabled=$gpsEnabled',
    );

    /// ✅ YOUR RULE:
    /// Fresh app launch + GPS OFF → ALWAYS ask
    /// Stored address is IGNORED here
    if (!gpsEnabled) {
      debugPrint('📣 GPS OFF on fresh launch → opening sheet');
      _openLocationSheet();
    } else {
      debugPrint('✅ GPS ON → no need to ask');
    }
  }

  // ===============================================================
  // 👉 USE CURRENT LOCATION (BUTTON TAP)
  // ===============================================================

  Future<void> _useCurrentLocation() async {
    debugPrint('👉 Use Current Location tapped');

    final hasPermission =
        await LocationHelper.requestPermissionFromUser();

    debugPrint('🔐 Permission result = $hasPermission');

    if (!hasPermission) {
      LocationState.setError('Location permission required');
      LocationHeaderController.instance.sync();
      debugPrint('❌ Permission denied');
      return;
    }

    /// 🚨 DO NOT fetch here
    /// Just open system settings
    debugPrint('⚙️ Opening system location settings');
    await LocationHelper.ensureLocationServiceEnabled();
  }

  // ===============================================================
  // 📡 FETCH + SAVE GPS LOCATION
  // ===============================================================

  Future<void> _fetchAndSaveLocation() async {
    debugPrint('🟡 startDetecting');

    LocationState.startDetecting();
    LocationHeaderController.instance.sync();

    final address =
        await LocationHelper.fetchCurrentAddress();

    debugPrint('📦 fetchCurrentAddress="$address"');

    if (address.isEmpty) {
      LocationState.setError('Unable to detect location');
      LocationHeaderController.instance.sync();
      debugPrint('❌ Address empty');
      return;
    }

    await LocationState.setGpsAddress(address);
    LocationHeaderController.instance.sync();

    debugPrint('✅ GPS location saved');

    if (_sheetOpen && mounted) {
      debugPrint('📤 Closing bottom sheet');
      Navigator.pop(context);
    }
  }

  // ===============================================================
  // 📂 OPEN LOCATION BOTTOM SHEET
  // ===============================================================

  void _openLocationSheet() {
    if (_sheetOpen || !mounted) {
      debugPrint('⛔ Sheet already open or widget disposed');
      return;
    }

    debugPrint('📂 Opening LocationBottomSheet');

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
          }) async {
            debugPrint('🏠 Saved address selected');

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
      debugPrint('📴 Bottom sheet closed');
      _sheetOpen = false;
    });
  }

  // ===============================================================
  // 🔁 APP LIFECYCLE — THIS IS THE KEY PART
  // ===============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('🔁 AppLifecycleState = $state');

    /// ✅ ONLY handle return from system settings
    if (state == AppLifecycleState.resumed) {
      final gpsEnabled =
          await LocationHelper.canUseLocationSilently();

      debugPrint('📡 GPS enabled on resume = $gpsEnabled');

      /// Fetch ONLY if:
      /// - User enabled GPS
      /// - Location not yet stored
      if (gpsEnabled &&
          !LocationState.hasPersistedLocation) {
        debugPrint('➡️ GPS enabled → fetching location');
        await _fetchAndSaveLocation();
      }
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
