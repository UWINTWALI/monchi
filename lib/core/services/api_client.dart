import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  ApiClient(this._dio, this._prefs) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(_tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        clearToken();
        return Exception('Unauthorized');
      }
      return Exception(
        error.response?.data?['message'] ?? 'Network error occurred',
      );
    }
    return Exception('An unexpected error occurred');
  }
}
