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
}