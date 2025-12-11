import '../constants/api_constants.dart';
import '../models/external_dish.dart';
import '../services/external_auth_service.dart';
import 'package:dio/dio.dart';

class ExternalRepository {
  final ExternalAuthService _externalAuthService;

  ExternalRepository({
    ExternalAuthService? externalAuthService,
  })  : _externalAuthService = externalAuthService ?? ExternalAuthService();

  Future<List<ExternalDish>> getFeaturedDishes() async {
    final res = await _runWithRetry(
      (dio) => dio.get(ApiConstants.externalDishes),
    );
    final data = res.data['data'];
    if (data is List) {
      return data.map((e) => ExternalDish.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getDishDetail(String id) async {
    final res = await _runWithRetry(
      (dio) => dio.get('${ApiConstants.externalDishes}/$id'),
    );
    final detail = res.data['detail'];
    if (detail is Map<String, dynamic>) {
      return detail;
    }
    throw Exception('Không có dữ liệu món ăn');
  }

  /// Execute the request and transparently refresh the token once on 401.
  Future<Response<dynamic>> _runWithRetry(
    Future<Response<dynamic>> Function(Dio dio) operation,
  ) async {
    var token = await _externalAuthService.ensureExternalToken();
    if (token == null || token.isEmpty) {
      throw Exception('Không lấy được token external');
    }

    try {
      return await operation(_buildDio(token));
    } on DioException catch (e) {
      // Retry once if the cached token is expired/invalid
      if (e.response?.statusCode == 401) {
        final refreshed = await _externalAuthService.refreshExternalToken();
        if (refreshed != null && refreshed.isNotEmpty) {
          return await operation(_buildDio(refreshed));
        }
      }
      rethrow;
    }
  }

  Dio _buildDio(String token) => Dio(
        BaseOptions(
          connectTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
}

