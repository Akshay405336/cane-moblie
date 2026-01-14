import 'package:flutter/material.dart';

/// Product image gallery
/// Used only in ProductDetailsScreen
class ProductImageGallery extends StatefulWidget {
  final String mainImage;
  final List<String> galleryImages;

  const ProductImageGallery({
    super.key,
    required this.mainImage,
    required this.galleryImages,
  });

  @override
  State<ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState
    extends State<ProductImageGallery> {
  late final List<String> _images;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 🔥 MAIN IMAGE ALWAYS FIRST
    _images = [
      widget.mainImage,
      ...widget.galleryImages,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* ================= IMAGE SLIDER ================= */

        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = _images[index];

              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        /* ================= INDICATORS ================= */

        if (_images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => _IndicatorDot(
                isActive: index == _currentIndex,
              ),
            ),
          ),
      ],
    );
  }
}

/* ================================================= */
/* INDICATOR DOT                                     */
/* ================================================= */

class _IndicatorDot extends StatelessWidget {
  final bool isActive;

  const _IndicatorDot({
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade600
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
