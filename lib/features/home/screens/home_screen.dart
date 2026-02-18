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
import '../widgets/home_top_banner.dart'; 

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
  
  // 🔥 NEW: Track the selected category (default to 'all')
  String _selectedCategoryId = 'all';

  /* ================= OUTLETS ================= */

  List<Outlet> _outlets = [];
  bool _loadingOutlets = true;

  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 HomeScreen init');

    CategorySocketService.subscribe(_onCategories);
    final cachedCategories = CategorySocketService.cachedCategories;

    if (cachedCategories.isNotEmpty) {
      _categories = _injectAllCategory(cachedCategories); // 🔥 Inject "All"
      _loadingCategories = false;
    }

    CategorySocketService.connect();
    
    OutletSocketService.instance.subscribe(_onOutlets);
  }

  /// 🔥 Helper to add the "All" category at the start of the list
  List<Category> _injectAllCategory(List<Category> incoming) {
    final allCategory = Category(
      id: 'all',
      name: 'All',// You can add a local asset path here if needed
    );
    
    // Check if it already exists to avoid duplicates
    if (incoming.any((c) => c.id == 'all')) return incoming;
    return [allCategory, ...incoming];
  }

  void _connectOutletSocket(double lat, double lng) {
    debugPrint('🚀 Connect outlets → $lat,$lng');
    setState(() => _loadingOutlets = true);
    
    OutletSocketService.instance.disconnect();
    OutletSocketService.instance.connect(lat: lat, lng: lng);
  }

  void _onCategories(List<Category> categories) {
    if (!mounted) return;
    debugPrint('📦 Categories received: ${categories.length}');
    setState(() {
      _categories = _injectAllCategory(categories); // 🔥 Inject "All"
      _loadingCategories = false;
    });
  }

  void _onOutlets(List<Outlet> outlets) {
    if (!mounted) return;
    
    final nearby = outlets.where((o) {
      if (o.distanceKm == null) return false;
      return o.distanceKm! <= 6;
    }).toList();

    debugPrint('🏪 Nearby outlets (≤6km): ${nearby.length}');
    setState(() {
      _outlets = nearby;
      _loadingOutlets = false;
    });
  }

  @override
  void dispose() {
    CategorySocketService.unsubscribe(_onCategories);
    OutletSocketService.instance.unsubscribe(_onOutlets);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();
    final lat = location.current?.latitude;
    final lng = location.current?.longitude;

    if (lat != null && lng != null && (_lastLat != lat || _lastLng != lng)) {
      _lastLat = lat;
      _lastLng = lng;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _connectOutletSocket(lat, lng);
      });
    }

    return Scaffold(
      backgroundColor: HomeColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: HomeSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* HEADER */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: HomeSpacing.lg),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3FBF5),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: const Column(
                  children: [
                    SizedBox(height: HomeSpacing.sm),
                    HomeSearchSection(),
                    SizedBox(height: HomeSpacing.md),
                    HomeTopBanner(),
                  ],
                ),
              ),

              /* CATEGORIES */
              const SizedBox(height: HomeSpacing.lg),
              // 🔥 UPDATED: Pass selected ID and a callback to update it
              HomeCategoriesSection(
                loading: _loadingCategories,
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onCategoryTap: (category) {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                  debugPrint('🎯 Selected Category: ${category.name}');
                },
              ),

              /* OUTLETS */
              const SizedBox(height: HomeSpacing.xl),
              // 🔥 UPDATED: Pass the selectedCategoryId to the outlets section for filtering
              HomeOutletsSection(
                loading: _loadingOutlets,
                outlets: _outlets,
                selectedCategoryId: _selectedCategoryId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}