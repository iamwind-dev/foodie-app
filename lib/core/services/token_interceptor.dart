import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';

/// Token Interceptor - Automatically add auth token to requests
class TokenInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - refresh token
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(ApiConstants.refreshTokenKey);
      
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final dio = Dio();
          final response = await dio.post(
            '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
            data: {'refresh_token': refreshToken},
          );
          
          final refreshed = AuthResponse.fromJson(response.data);
          
          // Save new tokens
          await prefs.setString(ApiConstants.tokenKey, refreshed.accessToken);
          await prefs.setString(ApiConstants.refreshTokenKey, refreshed.refreshToken);
          
          // Retry original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
          final cloneReq = await dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          
          return handler.resolve(cloneReq);
        } catch (e) {
          // Refresh failed - clear tokens and redirect to login
          await prefs.remove(ApiConstants.tokenKey);
          await prefs.remove(ApiConstants.refreshTokenKey);
          await prefs.remove(ApiConstants.userKey);
        }
      }
    }
    
    handler.next(err);
  }
}
