/// API Configuration
class ApiConstants {
  // Base URLs
  // On Android emulator, localhost is 10.0.2.2
  static const String baseUrl = 'https://api1-dot-subtle-seat-475108-v5.et.r.appspot.com';
  static const String devBaseUrl = 'https://api1-dot-subtle-seat-475108-v5.et.r.appspot.com';
  
  // Endpoints (FastAPI backend - see API_DOCUMENTATION.md)
  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
  
  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  
  // Recipes
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/{id}';
  static const String createRecipe = '/recipes';
  static const String updateRecipe = '/recipes/{id}';
  static const String deleteRecipe = '/recipes/{id}';
  static const String searchRecipes = '/recipes/search';
  
  // AI
  static const String generateRecipe = '/api/generate-recipe';
  static const String recipeFromImage = '/api/recipe-from-image';
  static const String scanRecipe = '/ai/scan';
  static const String analyzeIngredients = '/ai/analyze';
  static const String externalDishes = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/buyer/mon-an';
  
  // Categories & Tags
  static const String categories = '/categories';
  static const String countries = '/countries';
  static const String tags = '/tags';
  
  // Favorites
  static const String favoritesLegacy = '/favorites';
  static const String addFavorite = '/favorites';
  static const String removeFavorite = '/favorites/{id}';
  static const String favorites = '/api/favorites/'; // keep trailing slash to avoid 307 redirect
  static const String uploadFavoriteImage = '/api/favorites/upload-image';
  
  // External vendor API (auto-login)
  static const String externalLoginUrl = 'https://subtle-seat-475108-v5.et.r.appspot.com/api/auth/login';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String externalTokenKey = 'external_api_token';
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
