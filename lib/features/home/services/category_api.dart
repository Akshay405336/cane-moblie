import 'package:dio/dio.dart';

import '../../../network/http_client.dart';
import '../../../utils/api_error_handler.dart';
import '../../../utils/app_toast.dart';

import '../models/category.model.dart';

class CategoryApi {
  CategoryApi._();

  /* ================================================= */
  /* GET PUBLIC CATEGORIES                             */
  /* ================================================= */

  static Future<List<Category>> getAll() async {
    try {
      final response =
          await AppHttpClient.dio.get(
        '/public/categories',
      );

      // backend format:
      // { success, code, message, data: [] }

      final List list = response.data['data'] ?? [];

      return list
          .map(
            (e) => Category.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList()
        ..sort(
          (a, b) =>
              a.sortOrder.compareTo(b.sortOrder),
        );
    } on DioException catch (e) {
      final message =
          ApiErrorHandler.getMessage(e);
      AppToast.error(message);
      return [];
    }
  }
}
