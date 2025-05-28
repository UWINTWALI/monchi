import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestsApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://172.31.30.73:3000/api';
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<String>> getInterests() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.get(
        '$_baseUrl/user-metadata/interests',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> interests = response.data['interests'] ?? [];
        return interests.map((interest) => interest.toString()).toList();
      }
      throw Exception('Failed to load interests');
    } catch (e) {
      print('Error fetching interests: $e');
      throw Exception('Failed to load interests: $e');
    }
  }

  Future<void> addInterests(List<String> interests) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.post(
        '$_baseUrl/user-metadata/interests',
        data: {'interests': interests},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error adding interests: $e');
      throw Exception('Failed to add interests: $e');
    }
  }

  Future<void> updateInterests(List<String> interests) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.put(
        '$_baseUrl/user-metadata/interests',
        data: {'interests': interests},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error updating interests: $e');
      throw Exception('Failed to update interests: $e');
    }
  }

  Future<void> deleteInterests() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.delete(
        '$_baseUrl/user-metadata/interests',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error deleting interests: $e');
      throw Exception('Failed to delete interests: $e');
    }
  }
}
