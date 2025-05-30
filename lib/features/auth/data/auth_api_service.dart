import 'package:dio/dio.dart';
import '../../../core/config/env_config.dart';

class AuthApiService {
  final Dio _dio = Dio();

  Future<String> login(String email, String password) async {
    final url = '${EnvConfig.apiBaseUrl}/auth/login';
    try {
      final response = await _dio.post(
        url,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        // Save token as needed (e.g., SharedPreferences)
        return response.data['token'];
      } else {
        throw Exception('Login failed: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String token, String userId) async {
    try {
      final response = await _dio.get(
        '${EnvConfig.apiBaseUrl}/users/$userId',  // Updated endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get user info');
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }
}