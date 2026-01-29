import '../../../env.dart';
import '../../home/models/category.model.dart';
import 'product_unit.model.dart';
import 'product_rating.model.dart';

import '../../cart/models/cart_item.model.dart';

class Product {
  final String id;
  final Category category;
  final String name;
  final String slug;
  final double originalPrice;
  final double? discountPrice;

  /// RELATIVE path from backend
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
  /* SAFE HELPERS (🔥 FIXED)                           */
  /* ================================================= */

  /// Safely converts String/Int/Double to Double
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  /// Safely converts String/Int to Int
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
  
  /// Safely converts String/Num to Num (useful for generic numbers)
  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  /* ================================================= */
  /* JSON → PRODUCT                                    */
  /* ================================================= */

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',

      category: Category.empty(),

      name: json['productName'] ?? json['name'] ?? '',
      slug: json['slug'] ?? '',

      /// 🔥 FIX: Safe double parsing
      originalPrice: _toDouble(json['originalPrice'] ?? json['price']),

      discountPrice: json['discountPrice'] != null
          ? _toDouble(json['discountPrice'])
          : null,

      mainImage: json['mainImage'] ?? json['image'] ?? '',

      galleryImages: List<String>.from(json['galleryImages'] ?? []),

      /// 🔥 FIX: Safe number parsing for unit value
      unit: ProductUnit(
        value: _toNum(json['unitValue']), 
        type: json['unitType'] ?? '',
      ),

      tags: List<String>.from(json['tags'] ?? []),

      rating: ProductRating(
        average: _toDouble(json['ratingAverage']),
        count: _toInt(json['ratingCount']), // Safe int parsing
      ),

      shortDescription: json['shortDescription'],
      longDescription: json['longDescription'],

      isTrending: json['isTrending'] ?? false,
    );
  }

  /* ================================================= */
  /* IMAGE BUILDER                                     */
  /* ================================================= */

  String _buildUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final base = Env.baseUrl.replaceAll(RegExp(r'/$'), '');
    final clean = path.replaceAll(RegExp(r'^/'), '');

    return '$base/$clean';
  }

  /* ================================================= */
  /* IMAGE HELPERS                                     */
  /* ================================================= */

  String get mainImageUrl => _buildUrl(mainImage);

  List<String> get galleryImageUrls =>
      galleryImages.map(_buildUrl).toList();

  /* ================================================= */
  /* UI HELPERS                                        */
  /* ================================================= */

  double get displayPrice => discountPrice ?? originalPrice;

  bool get hasDiscount =>
      discountPrice != null && discountPrice! < originalPrice;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice - discountPrice!) / originalPrice) * 100).round();
  }

  /* ================================================= */
  /* CART HELPERS                                      */
  /* ================================================= */

  String get image => mainImageUrl;
  double get price => originalPrice;
  double? get discount => discountPrice;

  CartItem toCartItem({int quantity = 1}) {
    return CartItem(
      id: id,
      productId: id,
      name: name,
      image: image,
      quantity: quantity,
      unitPrice: price,
      discountPrice: discount,
      lineTotal: null,
    );
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
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      mainImage: mainImage ?? this.mainImage,
      galleryImages: galleryImages ?? this.galleryImages,
      unit: unit ?? this.unit,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      isTrending: isTrending ?? this.isTrending,
    );
  }
}