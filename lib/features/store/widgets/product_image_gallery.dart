import 'package:flutter/material.dart';
import '../../home/theme/home_colors.dart';
import '../../home/theme/home_spacing.dart';

/// Product image gallery
/// Used only in ProductDetailsScreen
class ProductImageGallery extends StatefulWidget {
  /// ✅ FULL URL
  final String mainImageUrl;

  /// ✅ FULL URLs
  final List<String> galleryImageUrls;

  const ProductImageGallery({
    super.key,
    required this.mainImageUrl,
    required this.galleryImageUrls,
  });

  @override
  State<ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState
    extends State<ProductImageGallery> {
  late final List<String> _images;
  int _currentIndex = 0;

  bool get _hasGallery => _images.length > 1;

  @override
  void initState() {
    super.initState();

    /// Remove empty & duplicate images
    final uniqueGalleryImages = widget.galleryImageUrls
        .where((url) =>
            url.trim().isNotEmpty &&
            url != widget.mainImageUrl)
        .toList();

    /// MAIN IMAGE ALWAYS FIRST
    _images = [
      widget.mainImageUrl,
      ...uniqueGalleryImages,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* ================= IMAGE VIEW ================= */

        Container(
          color: HomeColors.lightGrey.withOpacity(0.4),
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(HomeSpacing.md),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(HomeSpacing.radiusLg),
                child: Container(
                  color: HomeColors.pureWhite,
                  child: _hasGallery
                      ? _buildPageView()
                      : _buildSingleImage(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: HomeSpacing.sm),

        /* ================= INDICATORS ================= */

        if (_hasGallery)
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

  /* ================= PAGE VIEW ================= */

  Widget _buildPageView() {
    return PageView.builder(
      itemCount: _images.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return _NetworkImage(url: _images[index]);
      },
    );
  }

  /* ================= SINGLE IMAGE ================= */

  Widget _buildSingleImage() {
    return _NetworkImage(url: _images.first);
  }
}

/* ================================================= */
/* NETWORK IMAGE (REUSABLE & SAFE)                    */
/* ================================================= */

class _NetworkImage extends StatelessWidget {
  final String url;

  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: HomeColors.primaryGreen,
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.broken_image,
          size: 32,
          color: HomeColors.textLightGrey,
        ),
      ),
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
      width: isActive ? 14 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? HomeColors.primaryGreen
            : HomeColors.textLightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
