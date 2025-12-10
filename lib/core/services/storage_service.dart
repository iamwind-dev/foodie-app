import '../constants/api_constants.dart';
import 'api_service.dart';

class StorageService {
  final ApiService _apiService;
  StorageService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<String?> uploadRecipeImage(String filePath) async {
    final response = await _apiService.uploadFile(
      ApiConstants.uploadFavoriteImage,
      filePath,
    );
    return response.data?['url']?.toString();
  }
}

