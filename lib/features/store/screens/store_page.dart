import 'package:flutter/material.dart';

// MODELS
import '../models/outlet.model.dart';

// SERVICES
import '../services/outlet_api.dart';

// SCREENS
import 'outlet_products_screen.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // ⭐ State Variables
  List<Outlet> _outlets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOutlets();
  }

  // ⭐ Fetch Real Data
  Future<void> _fetchOutlets() async {
    // ⚠️ TODO: Use real user location (Geolocator) here.
    // For now, we use Bangalore coordinates to make the API call work.
    const double userLat = 12.9716;
    const double userLng = 77.5946;

    final data = await OutletApi.getNearby(lat: userLat, lng: userLng);

    if (!mounted) return;

    setState(() {
      _outlets = data;
      _isLoading = false;
    });
  }

  void _onOutletTap(Outlet outlet) {
    // Navigate to Products Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutletProductsScreen(outlet: outlet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchOutlets,
        color: const Color(0xFF1B5E20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 HEADER TEXT
              const Text(
                'Nearby Stores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Find fresh juice stores near your location 🌱',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF558B2F),
                ),
              ),

              const SizedBox(height: 24),

              // 🏬 STORE LIST BUILDER
              if (_isLoading)
                // Loading State
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: const Color(0xFF1B5E20)),
                  ),
                )
              else if (_outlets.isEmpty)
                // Empty State
                _buildEmptyState()
              else
                // Real Data List
                ..._outlets.map((outlet) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _StoreCard(
                        outlet: outlet,
                        onTap: () => _onOutletTap(outlet),
                      ),
                    )),

              const SizedBox(height: 24),

              // FOOTER
              Center(
                child: Text(
                  'More stores coming soon 🍹',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No stores found nearby",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ⭐ Separate Widget for cleaner code
class _StoreCard extends StatelessWidget {
  final Outlet outlet;
  final VoidCallback onTap;

  const _StoreCard({
    required this.outlet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logic for color based on status
    final isOpen = outlet.isOpen;

    // Green if Open, Red if Closed
    final statusColor = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final statusBg = isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // STORE ICON
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFE8F5E9).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store,
                color: Color(0xFF43A047),
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // STORE INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),

                  // Show Branch if available
                  if (outlet.branch.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      outlet.branch,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Mock Distance Logic (Since we don't calculate real distance yet)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: const Color(0xFF558B2F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "~ 2.5 km",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // STATUS BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                outlet.workingStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}