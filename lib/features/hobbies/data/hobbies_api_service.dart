import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HobbiesApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<String>> getHobbies() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.get(
        '$_baseUrl/user-metadata/hobbies',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> hobbies = response.data['hobbies'] ?? [];
        return hobbies.map((hobby) => hobby.toString()).toList();
      }
      throw Exception('Failed to load hobbies');
    } catch (e) {
      print('Error fetching hobbies: $e');
      throw Exception('Failed to load hobbies: $e');
    }
  }

  Future<void> addHobbies(List<String> hobbies) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.post(
        '$_baseUrl/user-metadata/hobbies',
        data: {'hobbies': hobbies},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error adding hobbies: $e');
      throw Exception('Failed to add hobbies: $e');
    }
  }

  Future<void> updateHobbies(List<String> hobbies) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.put(
        '$_baseUrl/user-metadata/hobbies',
        data: {'hobbies': hobbies},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error updating hobbies: $e');
      throw Exception('Failed to update hobbies: $e');
    }
  }

  Future<void> deleteHobbies() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.delete(
        '$_baseUrl/user-metadata/hobbies',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error deleting hobbies: $e');
      throw Exception('Failed to delete hobbies: $e');
    }
  }
}
