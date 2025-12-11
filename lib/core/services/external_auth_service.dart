import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Handles auto-login to external vendor API and stores the token for later use.
class ExternalAuthService {
  static const _username = 'widd';
  static const _password = '123456789';

  /// Ensure we have a cached external token; login if missing.
  Future<String?> ensureExternalToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(ApiConstants.externalTokenKey);
    // Refresh when missing or expired
    if (cached != null && cached.isNotEmpty && !_isExpired(cached)) {
      return cached;
    }
    return await _loginAndStore(prefs);
  }

  /// Force refresh the token.
  Future<String?> refreshExternalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await _loginAndStore(prefs);
  }

  Future<String?> _loginAndStore(SharedPreferences prefs) async {
    try {
      final dio = Dio();
      final res = await dio.post(
        ApiConstants.externalLoginUrl,
        data: {
          "ten_dang_nhap": _username,
          "mat_khau": _password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final token = res.data?['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(ApiConstants.externalTokenKey, token);
        return token;
      }
    } catch (_) {}
    return null;
  }

  /// Decode JWT payload and check the `exp` claim; treat missing/invalid as expired.
  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp is int) {
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return exp <= nowSeconds + 60; // add small skew
      }
    } catch (_) {}
    return true;
  }
}

