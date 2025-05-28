import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/schedule_page.dart';

class ScheduleApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://172.31.30.73:3000/api';
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.get(
        '$_baseUrl/schedules',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception('Failed to load schedules');
    } catch (e) {
      print('Error fetching schedules: $e');
      throw Exception('Failed to load schedules: $e');
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.post(
        '$_baseUrl/schedules',
        data: schedule.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error adding schedule: $e');
      throw Exception('Failed to add schedule: $e');
    }
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.put(
        '$_baseUrl/schedules/$id',
        data: schedule.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error updating schedule: $e');
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      await _dio.delete(
        '$_baseUrl/schedules/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error deleting schedule: $e');
      throw Exception('Failed to delete schedule: $e');
    }
  }
}
