import 'env_config.dart';

class ApiConfig {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String validateToken = '/auth/validate-token';

  // User endpoints
  static const String users = '/users';
  static const String createUser = '/users/create';
  static const String syncUser = '/users/sync';
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // User metadata endpoints
  static const String interests = '/metadata/interests';
  static const String skills = '/metadata/skills';
  static const String hobbies = '/metadata/hobbies';
}
