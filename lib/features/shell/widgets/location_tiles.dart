import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/saved_address.dart';

/// =====================================================
/// HANDLE
/// =====================================================
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
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
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}

/// =====================================================
/// LOCATION OFF / PERMISSION REQUIRED
/// =====================================================
class LocationPermissionOffTile extends StatelessWidget {
  final VoidCallback onEnable;

  const LocationPermissionOffTile({
    super.key,
    required this.onEnable,
  });

  static const Color green = Color(0xFF03B602);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          /// text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location access required',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enable location to show nearby stores',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// enable button
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detecting your location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF03B602),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we find your current location',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 14,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isDetecting ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.my_location,
                  color: Color(0xFF03B602)),
              const SizedBox(width: 14),

              const Expanded(
                child: Text(
                  'Use current location',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              if (isDetecting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
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
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color:
            isActive ? const Color(0xFF03B602) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              isActive ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isActive
          ? const Icon(Icons.check_circle,
              color: Color(0xFF03B602))
          : const Icon(Icons.chevron_right),
    );
  }
}

/// =====================================================
/// HELPERS
/// =====================================================
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
      padding: EdgeInsets.only(top: 24),
      child: Text(
        'No saved addresses yet',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
