import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.model.dart';
import '../../store/models/outlet.model.dart';

import '../services/category_socket_service.dart';
import '../../store/services/outlet_socket_service.dart';

import '../../location/state/location_controller.dart';

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

    debugPrint('🏠 HomeScreen init');

    /* ---------- categories ---------- */

    CategorySocketService.subscribe(_onCategories);

    final cachedCategories =
        CategorySocketService.cachedCategories;

    if (cachedCategories.isNotEmpty) {
      _categories = cachedCategories;
      _loadingCategories = false;
    }

    CategorySocketService.connect();

    /* ---------- outlets ---------- */

    OutletSocketService.subscribe(_onOutlets);
  }

  /* ================================================= */
  /* CONNECT SOCKET                                    */
  /* ================================================= */

  void _connectOutletSocket(double lat, double lng) {
    debugPrint('🚀 Connect outlets → $lat,$lng');

    setState(() => _loadingOutlets = true);

    OutletSocketService.disconnect();
    OutletSocketService.connect(lat: lat, lng: lng);
  }

  /* ================================================= */
  /* HANDLERS                                          */
  /* ================================================= */

  void _onCategories(List<Category> categories) {
    if (!mounted) return;

    debugPrint('📦 Categories received: ${categories.length}');

    setState(() {
      _categories = categories;
      _loadingCategories = false;
    });
  }

  void _onOutlets(List<Outlet> outlets) {
    if (!mounted) return;

    debugPrint('🏪 Outlets received: ${outlets.length}');

    setState(() {
      _outlets = outlets;
      _loadingOutlets = false;
    });
  }

  /* ================================================= */
  /* DISPOSE                                           */
  /* ================================================= */

  @override
  void dispose() {
    CategorySocketService.unsubscribe(_onCategories);
    OutletSocketService.unsubscribe(_onOutlets);
    super.dispose();
  }

  /* ================================================= */
  /* UI                                                */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    final lat = location.current?.latitude;
    final lng = location.current?.longitude;

    /// ⭐ connect only when coordinates change
    if (lat != null &&
        lng != null &&
        (_lastLat != lat || _lastLng != lng)) {
      _lastLat = lat;
      _lastLng = lng;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _connectOutletSocket(lat, lng);
      });
    }

    debugPrint(
        '🎨 Build → loading=$_loadingOutlets outlets=${_outlets.length}');

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
