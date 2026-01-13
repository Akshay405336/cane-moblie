import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/saved_address.dart';

// ---------------- HANDLE ----------------
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.green.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ---------------- TITLES ----------------
class BottomSheetTitle extends StatelessWidget {
  const BottomSheetTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Select delivery address',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1B5E20),
      ),
    );
  }
}

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
        color: Color(0xFF689F38),
      ),
    );
  }
}

// ---------------- CURRENT LOCATION ----------------
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
    return InkWell(
      onTap: isDetecting ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location,
                color: Color(0xFF2E7D32)),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Use current location',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            isDetecting
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: const CircleAvatar(radius: 10),
                  )
                : const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADDRESS TILE (DISPLAY ONLY) ----------------
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
    return InkWell(
      onTap: isActive ? null : onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isActive
            ? const Icon(Icons.check_circle,
                color: Colors.green)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ---------------- HELPERS ----------------
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

// ---------------- EMPTY ----------------
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
