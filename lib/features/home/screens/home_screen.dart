import 'package:flutter/material.dart';

import '../models/category.model.dart';
import '../../store/models/outlet.model.dart';

import '../services/category_socket_service.dart';
import '../../store/services/outlet_socket_service.dart';

import '../../../utils/location_state.dart';

import '../sections/home_search.section.dart';
import '../sections/home_categories.section.dart';
import '../sections/home_outlets.section.dart';
import '../widgets/home_banner_slider.section.dart';

import '../theme/home_colors.dart';
import '../theme/home_spacing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /* ================= CATEGORIES ================= */

  List<Category> _categories = [];
  bool _loadingCategories = true;

  /* ================= OUTLETS ================= */

  List<Outlet> _outlets = [];
  bool _loadingOutlets = true;

  double? _lastLat;
  double? _lastLng;

  /* ================================================= */
  /* INIT                                              */
  /* ================================================= */

  @override
  void initState() {
    super.initState();

    debugPrint('🏠 HomeScreen → initState');

    /* ---------- categories ---------- */

    CategorySocketService.subscribe(_onCategories);

    final cachedCategories =
        CategorySocketService.cachedCategories;

    if (cachedCategories.isNotEmpty) {
      debugPrint(
          '📦 Categories → using cache (${cachedCategories.length})');

      _categories = cachedCategories;
      _loadingCategories = false;
    }

    CategorySocketService.connect();
    debugPrint('🔌 Category socket connect called');

    /* ---------- outlets ---------- */

    OutletSocketService.subscribe(_onOutlets);

    final cachedOutlets =
        OutletSocketService.cachedOutlets;

    if (cachedOutlets.isNotEmpty) {
      debugPrint(
          '📦 Outlets → using cache (${cachedOutlets.length})');

      _outlets = cachedOutlets;
      _loadingOutlets = false;
    }

    /// ⭐ IMPORTANT
    _waitForLocationAndConnect();
  }

  /* ================================================= */
  /* WAIT FOR LOCATION → CONNECT SOCKET ⭐              */
  /* ================================================= */

  void _waitForLocationAndConnect() async {
    debugPrint('⏳ Home → waiting for location...');

    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));

      final lat = LocationState.latitude;
      final lng = LocationState.longitude;

      debugPrint(
          '📡 Checking coords → lat=$lat lng=$lng');

      if (lat == null || lng == null) continue;

      /// already connected with same coords → skip
      if (_lastLat == lat && _lastLng == lng) {
        debugPrint('⚠️ Same coords → skipping reconnect');
        continue;
      }

      _lastLat = lat;
      _lastLng = lng;

      debugPrint(
          '🚀 Connecting outlet socket with lat=$lat lng=$lng');

      setState(() {
        _loadingOutlets = true;
      });

      OutletSocketService.disconnect();
      debugPrint('🔌 Old outlet socket disconnected');

      OutletSocketService.connect(lat: lat, lng: lng);
      debugPrint('🔌 Outlet socket connect called');

      break;
    }
  }

  /* ================================================= */
  /* DISPOSE                                           */
  /* ================================================= */

  @override
  void dispose() {
    debugPrint('🛑 HomeScreen → dispose');

    CategorySocketService.unsubscribe(_onCategories);
    OutletSocketService.unsubscribe(_onOutlets);

    super.dispose();
  }

  /* ================================================= */
  /* HANDLERS                                          */
  /* ================================================= */

  void _onCategories(List<Category> categories) {
    if (!mounted) return;

    debugPrint(
        '📥 Categories received → ${categories.length}');

    setState(() {
      _categories = categories;
      _loadingCategories = false;
    });
  }

  void _onOutlets(List<Outlet> outlets) {
    if (!mounted) return;

    debugPrint(
        '🏪 Outlets received → ${outlets.length}');

    setState(() {
      _outlets = outlets;
      _loadingOutlets = false;
    });
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🎨 Home build → loadingOutlets=$_loadingOutlets outlets=${_outlets.length}');

    return Scaffold(
      backgroundColor: HomeColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: HomeSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              /* HEADER */

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  bottom: HomeSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3FBF5),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  children: [
                    SizedBox(height: HomeSpacing.sm),
                    HomeSearchSection(),
                    SizedBox(height: HomeSpacing.md),
                    HomeBannerSliderSection(),
                  ],
                ),
              ),

              /* CATEGORIES */

              const SizedBox(height: HomeSpacing.lg),

              HomeCategoriesSection(
                loading: _loadingCategories,
                categories: _categories,
              ),

              /* OUTLETS */

              const SizedBox(height: HomeSpacing.xl),

              HomeOutletsSection(
                loading: _loadingOutlets,
                outlets: _outlets,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
