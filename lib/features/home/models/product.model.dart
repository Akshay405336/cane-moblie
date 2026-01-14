/// Public Product model
/// Used for HOME / PRODUCT LIST / PRODUCT DETAILS (customer side)
class Product {
  final String id;

  final String name;
  final String slug;

  final double originalPrice;
  final double? discountPrice;

  final String mainImage;
  final List<String> galleryImages;

  final String? shortDescription;
  final String? longDescription;

  final bool isTrending;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.originalPrice,
    required this.discountPrice,
    required this.mainImage,
    required this.galleryImages,
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

      shortDescription:
          json['shortDescription'] as String?,

      longDescription:
          json['longDescription'] as String?,

      isTrending:
          json['trendState']['trending'] as bool,
    );
  }

  /* ================================================= */
  /* PRODUCT HELPERS (UI FRIENDLY)                     */
  /* ================================================= */

  /// Final price shown to customer
  double get displayPrice =>
      discountPrice ?? originalPrice;

  /// Check if product has discount
  bool get hasDiscount =>
      discountPrice != null &&
      discountPrice! < originalPrice;

  /// Discount percentage (optional UI badge)
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice - discountPrice!) /
                originalPrice) *
            100)
        .round();
  }

  /* ================================================= */
  /* PRODUCT → JSON (OPTIONAL)                         */
  /* ================================================= */

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'value': name,
      },
      'slug': {
        'value': slug,
      },
      'price': {
        'originalPrice': originalPrice,
        'discountPrice': discountPrice,
      },
      'images': {
        'mainImage': mainImage,
        'galleryImages': galleryImages,
      },
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'trendState': {
        'trending': isTrending,
      },
    };
  }

  /* ================================================= */
  /* COPY WITH (UI UPDATES)                            */
  /* ================================================= */

  Product copyWith({
    String? id,
    String? name,
    String? slug,
    double? originalPrice,
    double? discountPrice,
    String? mainImage,
    List<String>? galleryImages,
    String? shortDescription,
    String? longDescription,
    bool? isTrending,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      originalPrice:
          originalPrice ?? this.originalPrice,
      discountPrice:
          discountPrice ?? this.discountPrice,
      mainImage: mainImage ?? this.mainImage,
      galleryImages:
          galleryImages ?? this.galleryImages,
      shortDescription:
          shortDescription ?? this.shortDescription,
      longDescription:
          longDescription ?? this.longDescription,
      isTrending: isTrending ?? this.isTrending,
    );
  }
}
