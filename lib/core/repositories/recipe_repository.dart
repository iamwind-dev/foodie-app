import '../constants/api_constants.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeRepository {
  final ApiService _apiService;
  
  RecipeRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  /// Get all recipes
  Future<List<RecipeModel>> getRecipes({
    int page = 1,
    int limit = 40,
    String? category,
    String? country,
  }) async {
    final response = await _apiService.get(
      ApiConstants.recipes,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (country != null) 'country': country,
      },
    );
    
    final List<dynamic> data = response.data['recipes'];
    return data.map((json) => RecipeModel.fromJson(json)).toList();
  }
  
  /// Get recipe by ID
  Future<RecipeModel> getRecipeById(String id) async {
    final response = await _apiService.get(
      ApiConstants.recipeDetail.replaceAll('{id}', id),
    );
    
    return RecipeModel.fromJson(response.data);
  }
  
  /// Create recipe
  Future<RecipeModel> createRecipe({
    required String title,
    String? description,
    required List<String> ingredients,
    required List<String> instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    String? category,
    String? country,
    List<String>? tags,
  }) async {
    final response = await _apiService.post(
      ApiConstants.createRecipe,
      data: {
        'title': title,
        if (description != null) 'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        if (prepTime != null) 'prepTime': prepTime,
        if (cookTime != null) 'cookTime': cookTime,
        if (servings != null) 'servings': servings,
        if (difficulty != null) 'difficulty': difficulty,
        if (category != null) 'category': category,
        if (country != null) 'country': country,
        if (tags != null) 'tags': tags,
      },
    );
    
    return RecipeModel.fromJson(response.data);
  }
  
  /// Update recipe
  Future<RecipeModel> updateRecipe({
    required String id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    String? category,
    String? country,
    List<String>? tags,
  }) async {
    final response = await _apiService.put(
      ApiConstants.updateRecipe.replaceAll('{id}', id),
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (ingredients != null) 'ingredients': ingredients,
        if (instructions != null) 'instructions': instructions,
        if (prepTime != null) 'prepTime': prepTime,
        if (cookTime != null) 'cookTime': cookTime,
        if (servings != null) 'servings': servings,
        if (difficulty != null) 'difficulty': difficulty,
        if (category != null) 'category': category,
        if (country != null) 'country': country,
        if (tags != null) 'tags': tags,
      },
    );
    
    return RecipeModel.fromJson(response.data);
  }
  
  /// Delete recipe
  Future<void> deleteRecipe(String id) async {
    await _apiService.delete(
      ApiConstants.deleteRecipe.replaceAll('{id}', id),
    );
  }
  
  /// Search recipes
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final response = await _apiService.get(
      ApiConstants.searchRecipes,
      queryParameters: {'q': query},
    );
    
    final List<dynamic> data = response.data['recipes'];
    return data.map((json) => RecipeModel.fromJson(json)).toList();
  }
  
  /// Generate recipe with AI (ingredients or description)
  Future<Map<String, dynamic>> generateRecipe({
    List<String>? ingredients,
    String? description,
  }) async {
    if ((ingredients == null || ingredients.isEmpty) && (description == null || description.trim().isEmpty)) {
      throw Exception('Cần ít nhất danh sách nguyên liệu hoặc mô tả món ăn');
    }

    final data = <String, dynamic>{};
    if (ingredients != null && ingredients.isNotEmpty) {
      data['ingredients'] = ingredients;
    }
    if (description != null && description.trim().isNotEmpty) {
      data['description'] = description.trim();
    }

    final response = await _apiService.post(
      ApiConstants.generateRecipe,
      data: data,
    );
    
    return Map<String, dynamic>.from(response.data);
  }
  
  /// Generate recipe from image (Vision AI)
  Future<Map<String, dynamic>> generateRecipeFromImage(String imagePath) async {
    final response = await _apiService.uploadFile(
      ApiConstants.recipeFromImage,
      imagePath,
    );

    return Map<String, dynamic>.from(response.data);
  }
  
  /// Scan recipe from image
  Future<RecipeModel> scanRecipe(String imagePath) async {
    final response = await _apiService.uploadFile(
      ApiConstants.scanRecipe,
      imagePath,
    );
    
    return RecipeModel.fromJson(response.data);
  }
}
