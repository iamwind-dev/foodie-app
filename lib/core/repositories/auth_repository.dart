import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  /// Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Backend (bcrypt) rejects passwords >72 bytes; truncate to 72 chars to be safe
    final safePassword = password.length > 72 ? password.substring(0, 72) : password;

    final response = await _apiService.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': safePassword,
      },
    );
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
    await _saveUser(authResponse.user);
    
    return authResponse;
  }
  
  /// Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
    int? age,
    String? gender,
  }) async {
    // Backend (bcrypt) rejects passwords >72 bytes; truncate to 72 chars to be safe
    final safePassword = password.length > 72 ? password.substring(0, 72) : password;

    final response = await _apiService.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': safePassword,
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      },
    );
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
    await _saveUser(authResponse.user);
    
    return authResponse;
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (e) {
      // Continue even if API call fails
    } finally {
      await _clearTokens();
    }
  }
  
  /// Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Backend (bcrypt) rejects passwords >72 bytes; truncate to 72 chars to be safe
    final safeCurrentPassword = currentPassword.length > 72 
        ? currentPassword.substring(0, 72) 
        : currentPassword;
    final safeNewPassword = newPassword.length > 72 
        ? newPassword.substring(0, 72) 
        : newPassword;

    await _apiService.post(
      ApiConstants.changePassword,
      data: {
        'current_password': safeCurrentPassword,
        'new_password': safeNewPassword,
      },
    );
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(ApiConstants.tokenKey);
  }
  
  /// Get current user
  Future<UserData?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(ApiConstants.userKey);
    if (userJson != null) {
      return UserData.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }
  
  /// Save tokens
  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
    await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
  }
  
  /// Save user
  Future<void> _saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
  }
  
  /// Clear tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
    await prefs.remove(ApiConstants.userKey);
  }
}
