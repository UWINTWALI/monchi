import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class UserMetadataService {
  final ApiClient _apiClient;

  UserMetadataService(this._apiClient);

  // Interests
  Future<List<Map<String, dynamic>>> getInterests() async {
    try {
      final response = await _apiClient.get(ApiConfig.interests);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addInterests(List<String> interests) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.interests,
        data: {'interests': interests},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateInterests(List<String> interests) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.interests,
        data: {'interests': interests},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInterests(List<String> interests) async {
    try {
      await _apiClient.delete(
        ApiConfig.interests,
        data: {'interests': interests},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Skills
  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      final response = await _apiClient.get(ApiConfig.skills);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addSkills(List<String> skills) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.skills,
        data: {'skills': skills},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSkills(List<String> skills) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.skills,
        data: {'skills': skills},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSkills(List<String> skills) async {
    try {
      await _apiClient.delete(ApiConfig.skills, data: {'skills': skills});
    } catch (e) {
      rethrow;
    }
  }

  // Hobbies
  Future<List<Map<String, dynamic>>> getHobbies() async {
    try {
      final response = await _apiClient.get(ApiConfig.hobbies);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addHobbies(List<String> hobbies) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.hobbies,
        data: {'hobbies': hobbies},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateHobbies(List<String> hobbies) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.hobbies,
        data: {'hobbies': hobbies},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHobbies(List<String> hobbies) async {
    try {
      await _apiClient.delete(ApiConfig.hobbies, data: {'hobbies': hobbies});
    } catch (e) {
      rethrow;
    }
  }
}
