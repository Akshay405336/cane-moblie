import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LocationBottomSheet extends StatefulWidget {
  final Future<void> Function() onUseCurrentLocation;

  const LocationBottomSheet({
    Key? key,
    required this.onUseCurrentLocation,
  }) : super(key: key);

  @override
  State<LocationBottomSheet> createState() =>
      _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  bool _isDetecting = false;

  Future<void> _handleDetect() async {
    if (_isDetecting) return;

    setState(() => _isDetecting = true);

    try {
      await widget.onUseCurrentLocation();
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
          // 🌱 HEADER
          Row(
            children: const [
              Text('📍', style: TextStyle(fontSize: 26)),
              SizedBox(width: 8),
              Text(
                'Select delivery location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 😢 INFO BOX
          _isDetecting
              ? _shimmerBox(height: 52)
              : _infoBox(),

          const SizedBox(height: 20),

          // 🟢 PRIMARY ACTION
          GestureDetector(
            onTap: _isDetecting ? null : _handleDetect,
            child: _isDetecting
                ? _shimmerButton()
                : _enableLocationButton(),
          ),

          const SizedBox(height: 28),

          const Text(
            'Saved addresses',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _isDetecting
                    ? _shimmerCard()
                    : _emptyAddressCard(Icons.home_outlined, 'Home'),
                _isDetecting
                    ? _shimmerCard()
                    : _emptyAddressCard(Icons.work_outline, 'Work'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI PIECES ----------------

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Text('😢', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'We need your location to show nearby fresh juice stores.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6D4C41),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enableLocationButton() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF66BB6A),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.my_location, color: Colors.white, size: 26),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use current location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Detecting location automatically',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios,
              color: Colors.white, size: 16),
        ],
      ),
    );
  }

  // ---------------- SHIMMERS ----------------

  Widget _shimmerBox({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _shimmerButton() {
    return _shimmerBox(height: 72);
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _emptyAddressCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF81C784), size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF558B2F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Not added yet',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
