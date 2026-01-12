import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/location_state.dart';

class LocationBottomSheet extends StatelessWidget {
  final Future<void> Function() onUseCurrentLocation;

  const LocationBottomSheet({
    Key? key,
    required this.onUseCurrentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isDetecting = LocationState.isDetecting;

    return Container(
      height: height * 0.55,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FFF8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _permissionBanner(isDetecting),
          const SizedBox(height: 28),
          _addressHeader(),
          const SizedBox(height: 16),
          _addressGrid(),
        ],
      ),
    );
  }

  // ===============================================================
  // PERMISSION BANNER (UI ONLY)
  // ===============================================================

  Widget _permissionBanner(bool isDetecting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gps_fixed,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Location permission is off',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enable for accurate delivery',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isDetecting ? null : onUseCurrentLocation,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isDetecting
                ? _buttonShimmer()
                : const Text(
                    'ENABLE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _addressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Select delivery address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5E20),
          ),
        ),
        Text(
          'VIEW ALL',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // ADDRESS GRID
  // ===============================================================

  Widget _addressGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
        children: const [
          AddressPlaceholder(icon: Icons.home_outlined, label: 'Home'),
          AddressPlaceholder(icon: Icons.work_outline, label: 'Work'),
          AddNewAddressCard(),
        ],
      ),
    );
  }

  // ===============================================================
  // SHIMMER
  // ===============================================================

  Widget _buttonShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 48,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

// ===============================================================
// ADDRESS PLACEHOLDER
// ===============================================================

class AddressPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const AddressPlaceholder({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF81C784)),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF558B2F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Not added',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// ADD NEW ADDRESS CARD
// ===============================================================

class AddNewAddressCard extends StatelessWidget {
  const AddNewAddressCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: Color(0xFF2E7D32), size: 32),
          SizedBox(height: 8),
          Text(
            'Add new address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
