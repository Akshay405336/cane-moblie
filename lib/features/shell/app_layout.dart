import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/screens/home_screen.dart';
import '../cart/screens/cart_page.dart';
import '../reorder/screens/reorder_page.dart';
import '../store/screens/store_page.dart';
import '../explore/screens/explore_page.dart';

import '../../features/location/state/location_controller.dart';
import '../../features/location/services/location_service.dart';
import '../../features/saved_address/state/saved_address_controller.dart';

import 'widgets/app_header.dart';
import 'widgets/app_navbottom.dart';
import 'widgets/location_bottom_sheet.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  bool _sheetOpen = false;
  bool _initialized = false;

  final _pages = const [
    HomeScreen(),
    CartPage(),
    ReorderPage(),
    StorePage(),
    ExplorePage(),
  ];

  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    debugPrint('🟢 AppLayout initState');

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  /* ================================================= */
  /* BOOTSTRAP                                         */
  /* ================================================= */

  Future<void> _bootstrap() async {
    debugPrint('🚀 BOOTSTRAP START');

    final location = context.read<LocationController>();
    final saved = context.read<SavedAddressController>();

    try {
      await Future.wait([
        location.load(),
        saved.load(),
      ]);
    } catch (e) {
      debugPrint('❌ Bootstrap error: $e');
    }

    if (!mounted) return;

    setState(() => _initialized = true);

    final gpsEnabled =
        await LocationService.isGpsEnabled();

    debugPrint(
        '📍 hasLocation=${location.hasLocation} | gps=$gpsEnabled');

    if (!gpsEnabled || !location.hasLocation) {
      debugPrint('⚠️ Opening location sheet (auto)');
      _openLocationSheetAuto(); // ⭐ changed
    } else {
      debugPrint('✅ Location ready → skip sheet');
    }
  }

  /* ================================================= */
  /* ⭐ AUTO SHEET (system open)                        */
  /* ================================================= */

  void _openLocationSheetAuto() {
    if (_sheetOpen || !mounted) return;

    _sheetOpen = true;

    debugPrint('📂 Opening bottom sheet (auto)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const LocationBottomSheet(
        autoClose: true, // ⭐ auto close
      ),
    ).whenComplete(() {
      debugPrint('📴 Sheet closed');
      _sheetOpen = false;
    });
  }

  /* ================================================= */
  /* ⭐ MANUAL SHEET (header tap)                       */
  /* ================================================= */

  void _openLocationSheetManual() {
    if (_sheetOpen || !mounted) return;

    _sheetOpen = true;

    debugPrint('📂 Opening bottom sheet (manual)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const LocationBottomSheet(), // ⭐ no auto close
    ).whenComplete(() {
      debugPrint('📴 Sheet closed');
      _sheetOpen = false;
    });
  }

  /* ================================================= */
  /* LIFECYCLE                                         */
  /* ================================================= */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    final location = context.read<LocationController>();

    final gpsEnabled =
        await LocationService.isGpsEnabled();

    debugPrint(
        '🔁 Resume → hasLocation=${location.hasLocation} | gps=$gpsEnabled');

    if (!gpsEnabled) {
      debugPrint('⚠️ GPS OFF → opening sheet');
      _openLocationSheetAuto(); // ⭐ changed
      return;
    }

    if (!location.hasLocation && !location.isDetecting) {
      debugPrint('📡 Resume detect');
      location.detectCurrentLocation();
    }
  }

  /* ================================================= */
  /* DISPOSE                                           */
  /* ================================================= */

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        onLocationTap: _openLocationSheetManual, // ⭐ changed
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppNavBottom(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
