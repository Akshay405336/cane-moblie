/// Product unit model
/// Example: 1 LTR, 500 ML
class ProductUnit {
  final num value;
  final String type;

  const ProductUnit({
    required this.value,
    required this.type,
  });

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      value: json['value'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
    };
  }
}
