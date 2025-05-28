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
    print('Starting to parse JSON response');
    print('Raw JSON: $json');

    try {
      // Handle potential nested structure
      final Map<String, dynamic> data = json is Map
          ? (json['data'] is Map
                ? json['data']
                : json['user'] is Map
                ? json['user']
                : json)
          : throw Exception('Invalid JSON structure');

      print('Extracted data structure: $data');
      print('Available fields: ${data.keys.toList()}');

      // Helper function to get value checking both camelCase and snake_case
      String? getValue(String snakeCase, String camelCase) {
        return (data[snakeCase]?.toString() ?? data[camelCase]?.toString())
            ?.trim();
      }

      // Extract and validate date fields first
      DateTime? parsedDateOfBirth;
      DateTime parsedCreatedAt;
      DateTime parsedUpdatedAt;

      try {
        final dateOfBirthStr = getValue('date_of_birth', 'dateOfBirth');
        if (dateOfBirthStr != null && dateOfBirthStr.isNotEmpty) {
          parsedDateOfBirth = DateTime.parse(dateOfBirthStr);
        }

        parsedCreatedAt = DateTime.parse(
          getValue('created_at', 'createdAt') ??
              DateTime.now().toIso8601String(),
        );
        parsedUpdatedAt = DateTime.parse(
          getValue('updated_at', 'updatedAt') ??
              DateTime.now().toIso8601String(),
        );

        print('Parsed dates:');
        print('Date of Birth: $parsedDateOfBirth');
        print('Created At: $parsedCreatedAt');
        print('Updated At: $parsedUpdatedAt');
      } catch (e) {
        print('Error parsing dates: $e');
        print('Raw date values:');
        print(
          'date_of_birth/dateOfBirth: ${getValue('date_of_birth', 'dateOfBirth')}',
        );
        print('created_at/createdAt: ${getValue('created_at', 'createdAt')}');
        print('updated_at/updatedAt: ${getValue('updated_at', 'updatedAt')}');
        rethrow;
      }

      final firstName = getValue('first_name', 'firstName') ?? '';
      final lastName = getValue('last_name', 'lastName') ?? '';

      print('Extracted name values:');
      print('First Name: "$firstName"');
      print('Last Name: "$lastName"');

      final profile = UserProfile(
        uid: data['uid']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        username: data['username']?.toString() ?? '',
        firstName: firstName,
        lastName: lastName,
        gender: data['gender']?.toString(),
        dateOfBirth: parsedDateOfBirth,
        bio: data['bio']?.toString()?.trim(),
        profilePicture: getValue('profile_picture', 'profilePicture'),
        interests: List<String>.from(data['interests'] ?? []),
        skills: List<String>.from(data['skills'] ?? []),
        hobbies: List<String>.from(data['hobbies'] ?? []),
        createdAt: parsedCreatedAt,
        updatedAt: parsedUpdatedAt,
      );

      print('Successfully created UserProfile object');
      print('Final parsed values:');
      print('- First Name: "${profile.firstName}"');
      print('- Last Name: "${profile.lastName}"');
      print('- Date of Birth: ${profile.dateOfBirth}');

      return profile;
    } catch (e) {
      print('Error parsing UserProfile JSON: $e');
      print('Full JSON data received: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    String? formatDateToUTC(DateTime? date) {
      if (date == null) return null;
      final utcDate = DateTime.utc(
        date.year,
        date.month,
        date.day,
        12, // Use noon UTC to avoid any date shifting
      );
      return utcDate.toIso8601String();
    }

    final data = {
      'username': username.trim(),
      'email': email,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'gender': gender,
      'date_of_birth': formatDateToUTC(dateOfBirth),
      'bio': bio?.trim(),
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'interests': interests,
      'skills': skills,
      'hobbies': hobbies,
    };

    print('Preparing profile data for API:');
    print('- username: ${data['username']}');
    print('- first_name: ${data['first_name']}');
    print('- last_name: ${data['last_name']}');
    print('- date_of_birth: ${data['date_of_birth']}');

    return data;
  }
}

class UserApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://172.31.30.73:3000/api';
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
      print('Using token: ${token.substring(0, 10)}...');

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
      print('Raw API Response data type: ${response.data.runtimeType}');
      print('Raw API Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception('API returned null data');
        }

        // Convert response data to ensure proper structure
        final Map<String, dynamic> userData = Map<String, dynamic>.from(
          response.data,
        );

        // Debug log the specific fields we're interested in
        print('DEBUG - Raw field values from API:');
        print('first_name: ${userData['first_name']}');
        print('firstName: ${userData['firstName']}');
        print('last_name: ${userData['last_name']}');
        print('lastName: ${userData['lastName']}');
        print('All available keys: ${userData.keys.toList()}');

        final profile = UserProfile.fromJson(userData);

        // Verify the parsed data
        print('DEBUG - Parsed profile values:');
        print('First Name: "${profile.firstName}"');
        print('Last Name: "${profile.lastName}"');
        print('Date of Birth: ${profile.dateOfBirth}');

        return profile;
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
      print('Current username to be updated: ${profile.username}');

      final jsonData = profile.toJson();
      print('Profile data being sent to API:');
      print('- username: ${jsonData['username']}');
      print('- first_name: ${jsonData['first_name']}');
      print('- last_name: ${jsonData['last_name']}');
      print('Full request data: $jsonData');

      final response = await _dio.put(
        '$_baseUrl/users/$userId',
        data: jsonData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response data: ${response.data}');

      if (response.data != null && response.data is Map) {
        print('API Response username: ${response.data['username']}');
        if (response.data['error'] != null) {
          print('API Error: ${response.data['error']}');
          throw Exception(response.data['error']);
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      if (e.response?.data != null && e.response?.data['error'] != null) {
        throw Exception(e.response?.data['error']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }
}
