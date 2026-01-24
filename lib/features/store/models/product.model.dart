import '../../../env.dart';
import '../../home/models/category.model.dart';
import 'product_unit.model.dart';
import 'product_rating.model.dart';

/// Public Product model
/// Used for HOME / PRODUCT LIST / PRODUCT DETAILS
class Product {
  final String id;

  /// backend no longer sends category
  final Category category;

  final String name;
  final String slug;

  /// backend sends single "price"
  final double originalPrice;
  final double? discountPrice;

  /// backend sends "image"
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
  /* JSON → PRODUCT  ⭐ FIXED FOR PUBLIC API            */
  /* ================================================= */

  factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as String,

    /// backend doesn't send category
    category: Category.empty(),

    name: json['name'] as String,
    slug: json['slug'] as String,

    /// ⭐ SAFE parsing (handles "90" or 90)
    originalPrice:
        double.parse(json['price'].toString()),
    discountPrice: null,

    mainImage: json['image'] ?? '',

    galleryImages:
        List<String>.from(json['galleryImages'] ?? []),

    unit: ProductUnit(
      value: json['unitValue'] ?? 0,
      type: json['unitType'] ?? '',
    ),

    tags: List<String>.from(json['tags'] ?? []),

    rating: ProductRating(
      average: double.parse(
          json['ratingAverage'].toString()),
      count: json['ratingCount'] ?? 0,
    ),

    shortDescription: json['shortDescription'],
    longDescription: json['longDescription'],

    isTrending: json['isTrending'] ?? false,
  );
}

  /* ================================================= */
  /* IMAGE HELPERS                                     */
  /* ================================================= */

  String get mainImageUrl =>
      '${Env.baseUrl}/$mainImage';

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
