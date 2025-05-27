import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  AuthService(this._apiClient, this._prefs);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        final userId = response.data['userId'];

        if (token != null) {
          await _prefs.setString(_tokenKey, token);
          if (userId != null) {
            await _prefs.setString(_userIdKey, userId);
          }
          return response.data;
        }
      }
      throw Exception('Invalid credentials');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Clear all auth-related data
      await Future.wait([_prefs.remove(_tokenKey), _prefs.remove(_userIdKey)]);

      // Clear the token from API client
      _apiClient.clearToken();

      print('Logout successful - Token and userId cleared');
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  Future<bool> validateToken() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) return false;

      // Try to make a request to validate the token
      try {
        final response = await _apiClient.get(ApiConfig.validateToken);
        return response.statusCode == 200;
      } catch (e) {
        print('Token validation failed: $e');
        // If token is invalid, clear it
        await logout();
        return false;
      }
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  bool get isAuthenticated {
    final token = _prefs.getString(_tokenKey);
    return token != null;
  }

  String? get token => _prefs.getString(_tokenKey);

  String? get userId => _prefs.getString(_userIdKey);
}
