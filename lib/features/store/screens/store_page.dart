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

  /* ================================================= */
  /* FETCH ALL OUTLETS (NO LOCATION FILTER)             */
  /* ================================================= */

  Future<void> _fetchOutlets() async {
    setState(() => _isLoading = true);

    try {
      // ✅ FIX: Fetch ALL outlets (not nearby)
      final data = await OutletApi.getAll();

      if (!mounted) return;

      setState(() {
        _outlets = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load outlets: $e');

      if (!mounted) return;

      setState(() {
        _outlets = [];
        _isLoading = false;
      });
    }
  }

  void _onOutletTap(Outlet outlet) {
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* ================= HEADER ================= */

              const Text(
                'All Stores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Browse all available juice stores 🍹',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF558B2F),
                ),
              ),

              const SizedBox(height: 24),

              /* ================= STORE LIST ================= */

              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                )
              else if (_outlets.isEmpty)
                _buildEmptyState()
              else
                ..._outlets.map(
                  (outlet) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _StoreCard(
                      outlet: outlet,
                      onTap: () => _onOutletTap(outlet),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              /* ================= FOOTER ================= */

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

  /* ================================================= */
  /* EMPTY STATE                                       */
  /* ================================================= */

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No stores available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/* ================================================= */
/* STORE CARD (UNCHANGED)                            */
/* ================================================= */

class _StoreCard extends StatelessWidget {
  final Outlet outlet;
  final VoidCallback onTap;

  const _StoreCard({
    required this.outlet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = outlet.isOpen;

    final statusColor =
        isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final statusBg =
        isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC);

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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFE8F5E9).withOpacity(0.8),
                  ],
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

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
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
