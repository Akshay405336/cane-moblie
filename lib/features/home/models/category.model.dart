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
  /* JSON                                              */
  /* ================================================= */

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }

  /* ================================================= */
  /* ⭐ SAFE EMPTY CATEGORY (NEW)                       */
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

    return '${Env.baseUrl}/$imagePath';
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
