import '../../../env.dart';

/// Public Category model
/// Used for HOME / EXPLORE / Product mapping
class Category {
  final String id;
  final String name;
  final String? imagePath;

  const Category({
    required this.id,
    required this.name,
    this.imagePath,
  });

  /* ================================================= */
  /* JSON → CATEGORY (🔥 UPDATED FOR FLEXIBILITY)      */
  /* ================================================= */

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      // Ensure ID is always a String
      id: (json['id'] ?? '').toString(),
      
      // Support 'name' or 'categoryName'
      name: json['name']?.toString() ?? json['categoryName']?.toString() ?? 'General',
      
      // 🔥 FIX: Backend uses 'imagePath' in sockets but 'image' in product nested objects
      imagePath: json['imagePath']?.toString() ?? json['image']?.toString(),
    );
  }

  /* ================================================= */
  /* ⭐ SAFE EMPTY CATEGORY                            */
  /* ================================================= */

  factory Category.empty() {
    return const Category(
      id: '',
      name: 'General',
      imagePath: null,
    );
  }

  /* ================================================= */

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }

  /// 🔥 FULL IMAGE URL FOR FLUTTER UI
  String? get imageUrl {
    if (imagePath == null || imagePath!.isEmpty) {
      return null;
    }
    
    // If it's already a full URL, return it
    if (imagePath!.startsWith('http')) return imagePath;

    // Clean slashes to prevent double-slash errors
    final cleanBase = Env.baseUrl.replaceAll(RegExp(r'/$'), '');
    final cleanPath = imagePath!.replaceAll(RegExp(r'^/'), '');

    return '$cleanBase/$cleanPath';
  }

  Category copyWith({
    String? id,
    String? name,
    String? imagePath,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}