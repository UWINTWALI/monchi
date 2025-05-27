import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'user_metadata_service.dart';

class ServiceProvider {
  static ServiceProvider? _instance;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final SharedPreferences _prefs;
  late final UserService userService;
  late final UserMetadataService userMetadataService;

  ServiceProvider._();

  static Future<ServiceProvider> getInstance() async {
    if (_instance == null) {
      _instance = ServiceProvider._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _apiClient = ApiClient(dio, _prefs);
    _authService = AuthService(_apiClient, _prefs);
    userService = UserService(_apiClient);
    userMetadataService = UserMetadataService(_apiClient);
  }

  ApiClient get apiClient => _apiClient;
  AuthService get authService => _authService;
}
