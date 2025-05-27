import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? profilePicture;
  final List<String> interests;
  final List<String> skills;
  final List<String> hobbies;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.profilePicture,
    this.interests = const [],
    this.skills = const [],
    this.hobbies = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON response: $json');
    try {
      return UserProfile(
        uid: json['uid'] ?? '',
        email: json['email'] ?? '',
        username: json['username'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        gender: json['gender'],
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'])
            : null,
        bio: json['bio'],
        profilePicture: json['profilePicture'],
        interests: List<String>.from(json['interests'] ?? []),
        skills: List<String>.from(json['skills'] ?? []),
        hobbies: List<String>.from(json['hobbies'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing UserProfile JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'profilePicture': profilePicture,
    };
  }
}

class UserApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: ${token?.substring(0, 10)}...');
    return token;
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    print('Retrieved user ID: $userId');
    return userId;
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (token == null) throw Exception('No authentication token found');
      if (userId == null) throw Exception('No user ID found');

      print('Fetching profile for user: $userId');
      final response = await _dio.get(
        '$_baseUrl/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('API Response status: ${response.statusCode}');
      print('API Response data: ${response.data}');

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
      throw Exception('Failed to load user profile: ${response.statusCode}');
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();
      if (token == null) throw Exception('No authentication token found');
      if (userId == null) throw Exception('No user ID found');

      print('Updating profile for user: $userId');
      final response = await _dio.put(
        '$_baseUrl/users/$userId',
        data: profile.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }
}
