import 'package:monchi/core/services/user_service.dart';
import 'package:monchi/core/services/user_metadata_service.dart';
import 'package:monchi/core/services/service_provider.dart';

class ProfileService {
  final UserService _userService;
  final UserMetadataService _metadataService;

  ProfileService(this._userService, this._metadataService);

  static Future<ProfileService> getInstance() async {
    final provider = await ServiceProvider.getInstance();
    return ProfileService(provider.userService, provider.userMetadataService);
  }

  Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      final userData = await _userService.getUserById(uid);

      // Fetch metadata in parallel for better performance
      final futures = await Future.wait([
        _metadataService.getInterests(),
        _metadataService.getSkills(),
        _metadataService.getHobbies(),
      ]);

      return {
        ...userData,
        'interests': futures[0],
        'skills': futures[1],
        'hobbies': futures[2],
      };
    } catch (e) {
      print('Error fetching profile: $e');
      // Return empty data structure to prevent null errors
      return {
        'firstName': '',
        'lastName': '',
        'dateOfBirth': '',
        'sex': null,
        'bio': '',
        'interests': [],
        'skills': [],
        'hobbies': [],
      };
    }
  }

  Future<void> updateProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Update basic user data
      await _userService.updateUser(uid, {
        'firstName': profileData['firstName'],
        'lastName': profileData['lastName'],
        'dateOfBirth': profileData['dateOfBirth'],
        'sex': profileData['sex'],
        'bio': profileData['bio'],
      });

      // Update metadata in parallel for better performance
      await Future.wait([
        if (profileData['interests'] != null)
          _metadataService.updateInterests(
            List<String>.from(profileData['interests']),
          ),
        if (profileData['skills'] != null)
          _metadataService.updateSkills(
            List<String>.from(profileData['skills']),
          ),
        if (profileData['hobbies'] != null)
          _metadataService.updateHobbies(
            List<String>.from(profileData['hobbies']),
          ),
      ]);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
