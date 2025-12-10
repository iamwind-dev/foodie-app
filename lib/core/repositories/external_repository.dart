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
    final token = await _externalAuthService.ensureExternalToken();
    if (token == null || token.isEmpty) {
      throw Exception('Không lấy được token external');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ));

    final res = await dio.get(ApiConstants.externalDishes);
    final data = res.data['data'];
    if (data is List) {
      return data.map((e) => ExternalDish.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getDishDetail(String id) async {
    final token = await _externalAuthService.ensureExternalToken();
    if (token == null || token.isEmpty) {
      throw Exception('Không lấy được token external');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ));

    final res = await dio.get('${ApiConstants.externalDishes}/$id');
    final detail = res.data['detail'];
    if (detail is Map<String, dynamic>) {
      return detail;
    }
    throw Exception('Không có dữ liệu món ăn');
  }
}

