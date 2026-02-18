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
  /* SAFE HELPERS                                      */
  /* ================================================= */

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
  
  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  /* ================================================= */
  /* JSON → PRODUCT (🔥 FIXED PRICE NESTING)           */
  /* ================================================= */

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. 🔥 HANDLE NESTED VALUE OBJECTS (Handles name: { value: "..." })
    String parseValue(dynamic data) {
      if (data == null) return '';
      if (data is Map) return (data['value'] ?? '').toString();
      return data.toString();
    }

    final String parsedName = parseValue(json['name']);
    final String parsedSlug = parseValue(json['slug']);

    // 2. 🔥 ROBUST CATEGORY HUNTING
    String foundCatId = '';
    String foundCatName = 'General';

    if (json['category'] != null && json['category'] is Map) {
      final catMap = json['category'] as Map<String, dynamic>;
      foundCatId = (catMap['id'] ?? catMap['_id'] ?? '').toString();
      foundCatName = (catMap['name'] ?? 'General').toString();
    } else if (json['categoryId'] != null) {
      foundCatId = json['categoryId'].toString();
    }

    // 3. 🚨 EMERGENCY FALLBACK: Match by name if API sent NO category data
    if (foundCatId.isEmpty) {
      final lowerName = parsedName.toLowerCase();
      if (lowerName.contains('coconut')) {
        foundCatId = 'f9cf5a27-53f3-4f87-87e6-48ea45ed1eb1';
        foundCatName = "Coconut Juice's";
      } else if (lowerName.contains('sugarcane')) {
        foundCatId = '1e66591c-7add-4273-9dac-e99378a54a32';
        foundCatName = "Sugarcane Juice's";
      }
    }

    // 4. 🔥 PRICE MAPPING FIX (Handles both nested Map and flat Double)
    double original = 0.0;
    double? discount;

    if (json['price'] != null && json['price'] is Map) {
      // If backend sends: "price": {"originalPrice": 100, "discountPrice": 60}
      original = _toDouble(json['price']['originalPrice']);
      discount = json['price']['discountPrice'] != null 
          ? _toDouble(json['price']['discountPrice']) 
          : null;
    } else {
      // Fallback for flat keys: "originalPrice": 100
      original = _toDouble(json['originalPrice'] ?? json['price']);
      discount = json['discountPrice'] != null ? _toDouble(json['discountPrice']) : null;
    }

    // 5. 🔥 IMAGE SAFETY
    String rawImage = '';
    if (json['images'] != null && json['images'] is Map) {
      rawImage = (json['images']['mainImage'] ?? '').toString();
    } else {
      rawImage = (json['mainImage'] ?? json['image'] ?? '').toString();
    }
    if (rawImage.isEmpty) rawImage = 'images/placeholder_product.png';

    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      category: Category(id: foundCatId, name: foundCatName),
      name: parsedName,
      slug: parsedSlug,
      originalPrice: original,
      discountPrice: discount,
      mainImage: rawImage,
      galleryImages: json['images'] is Map 
          ? List<String>.from(json['images']['galleryImages'] ?? [])
          : List<String>.from(json['galleryImages'] ?? []),
      unit: ProductUnit(
        value: _toNum(json['unit'] is Map ? json['unit']['value'] : json['unitValue']), 
        type: (json['unit'] is Map ? json['unit']['type'] : (json['unitType'] ?? 'PCS')).toString(),
      ),
      tags: List<String>.from(json['tags'] ?? []),
      rating: ProductRating(
        average: _toDouble(json['rating'] is Map ? json['rating']['average'] : json['ratingAverage']),
        count: _toInt(json['rating'] is Map ? json['rating']['count'] : json['ratingCount']),
      ),
      shortDescription: json['shortDescription']?.toString(),
      longDescription: json['longDescription']?.toString(),
      isTrending: (json['trendState'] != null && json['trendState']['trending'] == true) || 
                  (json['isTrending'] ?? false),
    );
  }

  /* ================================================= */
  /* HELPERS & GETTERS                                 */
  /* ================================================= */

  String _buildUrl(String path) {
    if (path.isEmpty || path == 'images/placeholder_product.png') {
       return "https://via.placeholder.com/300"; 
    }
    if (path.startsWith('http')) return path;
    final base = Env.baseUrl.replaceAll(RegExp(r'/$'), '');
    final clean = path.replaceAll(RegExp(r'^/'), '');
    return '$base/$clean';
  }

  String get mainImageUrl => _buildUrl(mainImage);
  List<String> get galleryImageUrls => galleryImages.map(_buildUrl).toList();
  double get displayPrice => discountPrice ?? originalPrice;
  bool get hasDiscount => discountPrice != null && discountPrice! < originalPrice;

  int get discountPercent {
    if (!hasDiscount || originalPrice == 0) return 0;
    return (((originalPrice - discountPrice!) / originalPrice) * 100).round();
  }

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