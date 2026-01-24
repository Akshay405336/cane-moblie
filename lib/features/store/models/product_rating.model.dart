/// Product rating model
class ProductRating {
  final double average;
  final int count;

  const ProductRating({
    required this.average,
    required this.count,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      average: (json['average'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
    };
  }
}
