/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String code;
  final String message;
  final T data;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
    );
  }
}
