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

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;
  bool _sheetOpen = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationState.load();

      // 🔐 DO NOTHING ELSE
      // ❌ No GPS
      // ❌ No permission check
      // ❌ No auto bottom sheet
      setState(() {});
    });
  }

  // ===============================================================
  // USER-TRIGGERED GPS FLOW ONLY
  // ===============================================================

  Future<void> _useCurrentLocation() async {
    LocationState.startDetecting();
    setState(() {});

    final ready =
        await LocationHelper.requestLocationAccessFromUser();

    if (!ready) {
      LocationState.setError('Location permission required');
      setState(() {});
      return;
    }

    try {
      final address =
          await LocationHelper.fetchCurrentAddress();

      if (address.isEmpty) {
        LocationState.setError('Unable to detect location');
        setState(() {});
        return;
      }

      await LocationState.setGpsAddress(address);

      if (_sheetOpen && mounted) {
        Navigator.pop(context);
      }

      setState(() {});
    } catch (_) {
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
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
