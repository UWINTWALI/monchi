import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  // Create a new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.createUser,
        data: userData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _apiClient.get(ApiConfig.users);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String uid) async {
    try {
      final response = await _apiClient.get('${ApiConfig.users}/$uid');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.users}/$uid',
        data: userData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _apiClient.delete('${ApiConfig.users}/$uid');
    } catch (e) {
      rethrow;
    }
  }

  // Sync user data
  Future<Map<String, dynamic>> syncUser(Map<String, dynamic> syncData) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.syncUser,
        data: syncData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
