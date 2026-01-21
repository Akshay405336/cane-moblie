import '../../../env.dart';
import 'category.model.dart';
import 'product_unit.model.dart';
import 'product_rating.model.dart';

/// Public Product model
/// Used for HOME / PRODUCT LIST / PRODUCT DETAILS
class Product {
  final String id;

  final Category category;

  final String name;
  final String slug;

  final double originalPrice;
  final double? discountPrice;

  /// Relative paths from backend
  final String mainImage;
  final List<String> galleryImages;

  final ProductUnit unit;
  final List<String> tags;
  final ProductRating rating;

  final String? shortDescription;
  final String? longDescription;

  final bool isTrending;

  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.slug,
    required this.originalPrice,
    required this.discountPrice,
    required this.mainImage,
    required this.galleryImages,
    required this.unit,
    required this.tags,
    required this.rating,
    required this.shortDescription,
    required this.longDescription,
    required this.isTrending,
  });

  /* ================================================= */
  /* JSON → PRODUCT                                    */
  /* ================================================= */

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,

      category: Category.fromJson(
        json['category'],
      ),

      name: json['name']['value'] as String,
      slug: json['slug']['value'] as String,

      originalPrice:
          (json['price']['originalPrice'] as num)
              .toDouble(),

      discountPrice:
          json['price']['discountPrice'] != null
              ? (json['price']['discountPrice'] as num)
                  .toDouble()
              : null,

      mainImage:
          json['images']['mainImage'] as String,

      galleryImages:
          (json['images']['galleryImages'] as List)
              .map((e) => e as String)
              .toList(),

      unit: ProductUnit.fromJson(
        json['unit'],
      ),

      tags: List<String>.from(
        json['tags'] ?? [],
      ),

      rating: ProductRating.fromJson(
        json['rating'],
      ),

      shortDescription:
          json['shortDescription'] as String?,

      longDescription:
          json['longDescription'] as String?,

      isTrending:
          json['trendState']['trending'] as bool,
    );
  }

  /* ================================================= */
  /* 🔥 IMAGE URL HELPERS (FIX)                         */
  /* ================================================= */

  /// Full URL for main image
  String get mainImageUrl =>
      '${Env.baseUrl}/$mainImage';

  /// Full URLs for gallery images
  List<String> get galleryImageUrls =>
      galleryImages
          .where((e) => e.isNotEmpty)
          .map((e) => '${Env.baseUrl}/$e')
          .toList();

  /* ================================================= */
  /* UI HELPERS                                        */
  /* ================================================= */

  double get displayPrice =>
      discountPrice ?? originalPrice;

  bool get hasDiscount =>
      discountPrice != null &&
      discountPrice! < originalPrice;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice - discountPrice!) /
                originalPrice) *
            100)
        .round();
  }

  /* ================================================= */
  /* COPY WITH                                         */
  /* ================================================= */

  Product copyWith({
    String? id,
    Category? category,
    String? name,
    String? slug,
    double? originalPrice,
    double? discountPrice,
    String? mainImage,
    List<String>? galleryImages,
    ProductUnit? unit,
    List<String>? tags,
    ProductRating? rating,
    String? shortDescription,
    String? longDescription,
    bool? isTrending,
  }) {
    return Product(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      originalPrice:
          originalPrice ?? this.originalPrice,
      discountPrice:
          discountPrice ?? this.discountPrice,
      mainImage: mainImage ?? this.mainImage,
      galleryImages:
          galleryImages ?? this.galleryImages,
      unit: unit ?? this.unit,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      shortDescription:
          shortDescription ?? this.shortDescription,
      longDescription:
          longDescription ?? this.longDescription,
      isTrending: isTrending ?? this.isTrending,
    );
  }
}
