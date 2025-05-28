import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/env_config.dart'; // <-- Import EnvConfig

class SkillsApiService {
  final Dio _dio = Dio();
  static String get _baseUrl => EnvConfig.apiBaseUrl; // Use EnvConfig
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<String>> getSkills() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.get(
        '$_baseUrl/user-metadata/skills',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> skills = response.data['skills'] ?? [];
        return skills.map((skill) => skill.toString()).toList();
      }
      throw Exception('Failed to load skills');
    } catch (e) {
      print('Error fetching skills: $e');
      throw Exception('Failed to load skills: $e');
    }
  }

  Future<void> addSkills(List<String> skills) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.post(
        '$_baseUrl/user-metadata/skills',
        data: {'skills': skills},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error adding skills: $e');
      throw Exception('Failed to add skills: $e');
    }
  }

  Future<void> updateSkills(List<String> skills) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.put(
        '$_baseUrl/user-metadata/skills',
        data: {'skills': skills},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error updating skills: $e');
      throw Exception('Failed to update skills: $e');
    }
  }

  Future<void> deleteSkills() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.delete(
        '$_baseUrl/user-metadata/skills',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error deleting skills: $e');
      throw Exception('Failed to delete skills: $e');
    }
  }
}
