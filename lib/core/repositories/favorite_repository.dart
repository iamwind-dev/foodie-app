import '../constants/api_constants.dart';
import '../services/api_service.dart';

class FavoriteRepository {
  final ApiService _apiService;

  FavoriteRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<void> saveFavorite({
    required String title,
    String? time,
    String? calories,
    String? mode,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    await _apiService.post(
      ApiConstants.favorites,
      data: {
        'title': title,
        if (time != null) 'time': time,
        if (calories != null) 'calories': calories,
        if (mode != null) 'mode': mode,
        if (imageUrl != null) 'image_url': imageUrl,
        if (data != null) 'data': data,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final res = await _apiService.get(ApiConstants.favorites);
    final data = res.data['data'];
    if (data is List) {
      return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}

