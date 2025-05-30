import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/env_config.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthApiService _apiService = AuthApiService();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final url = '${EnvConfig.apiBaseUrl}/auth/login';
      print('Attempting to login with URL: $url');

      final token = await _apiService.login(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      return {'token': token};
    } catch (e) {
      print('Login error details: $e');
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _auth.signOut(),
      prefs.remove(_tokenKey),
      prefs.remove(_userIdKey),
    ]);
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}