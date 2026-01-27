import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../saved_address/models/saved_address.model.dart';

const _green = Color(0xFF03B602);

/// =====================================================
/// HANDLE
/// =====================================================

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// =====================================================
/// SECTION TITLE
/// =====================================================

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// =====================================================
/// LOCATION OFF / PERMISSION REQUIRED
/// =====================================================
/// ⭐ IMPORTANT: keep onEnablePressed (used by sheet)
/// =====================================================

class LocationPermissionOffTile extends StatelessWidget {
  final VoidCallback onEnablePressed;

  const LocationPermissionOffTile({
    super.key,
    required this.onEnablePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        children: [
          const Icon(Icons.location_off_rounded, color: _green),
          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location access required',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Turn on GPS to detect your address',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: onEnablePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              elevation: 0,
              minimumSize: const Size(72, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

/// =====================================================
/// FETCHING LOCATION
/// =====================================================

class LocationFetchingTile extends StatelessWidget {
  const LocationFetchingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detecting your location...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
          const SizedBox(height: 14),

          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================
/// CURRENT LOCATION
/// =====================================================

class CurrentLocationTile extends StatelessWidget {
  final bool isDetecting;
  final VoidCallback onTap;

  const CurrentLocationTile({
    super.key,
    required this.isDetecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDetecting ? 0.6 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isDetecting ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: _green),
                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use current location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Detect automatically using GPS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isDetecting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================================================
/// ADDRESS TILE
/// =====================================================

class AddressTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const AddressTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? _green.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: isActive ? _green : Colors.grey),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isActive ? _green : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (isActive)
                const Icon(Icons.check_circle, color: _green)
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================================================
/// HELPERS
/// =====================================================

BoxDecoration _box() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    );

IconData iconForType(SavedAddressType type) {
  switch (type) {
    case SavedAddressType.home:
      return Icons.home_outlined;
    case SavedAddressType.work:
      return Icons.work_outline;
    case SavedAddressType.other:
      return Icons.location_on_outlined;
  }
}

class EmptySavedAddress extends StatelessWidget {
  const EmptySavedAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        'No saved addresses yet',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
