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
  bool _locationSheetShown = false;

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

    // 🔥 Load saved location first, then enforce if missing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationState.load();
      _ensureLocation();
      setState(() {}); // refresh header after load
    });
  }

  /// 📍 REAL LOCATION FLOW (guest + logged-in)
  Future<void> _ensureLocation() async {
    // Already selected → nothing to do
    if (LocationState.hasLocation) return;

    // Prevent multiple sheets
    if (_locationSheetShown) return;
    _locationSheetShown = true;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false, // Swiggy-style
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return LocationBottomSheet(
          onUseCurrentLocation: () async {
            try {
              // ✨ START SHIMMER IN HEADER
              LocationState.startDetecting();
              setState(() {});

              // 1️⃣ Ensure GPS + permission
              await LocationHelper.ensureLocationReady();

              // 2️⃣ Fetch address
              final address =
                  await LocationHelper.fetchAddress();

              // 3️⃣ Save + persist
              await LocationState.setAddress(address);

              // ✨ STOP SHIMMER
              LocationState.stopDetecting();

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            } catch (_) {
              // ✨ STOP SHIMMER EVEN ON FAILURE
              LocationState.stopDetecting();
              setState(() {});
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌱 HEADER (location shimmer reacts here)
      appBar: AppHeader(
        onAuthChanged: () {
          setState(() {});
        },
      ),

      // 📄 BODY
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 🧭 BOTTOM NAV
      bottomNavigationBar: AppNavBottom(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
