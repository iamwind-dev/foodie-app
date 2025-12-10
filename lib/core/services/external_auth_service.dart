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
    if (cached != null && cached.isNotEmpty) return cached;
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
}

