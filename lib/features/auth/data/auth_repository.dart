import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio _dio = Dio();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      print(
        'Attempting to login with URL: http://172.31.30.73:3000/api/auth/login',
      );

      // First, authenticate with Firebase to maintain Firestore access
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Then authenticate with custom API
      final response = await _dio.post(
        // 'http://10.0.2.2:3000/api/auth/login',
        'http://172.31.30.73:3000/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          validateStatus: (status) => true,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 404) {
        throw Exception(
          'Endpoint not found (404). Please check if the server is running and the endpoint is correct',
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = response.data['token'];
        final userId = response.data['userId'];

        if (token != null) {
          await prefs.setString(_tokenKey, token);
          if (userId != null) {
            await prefs.setString(_userIdKey, userId);
          }
          return {...response.data, 'firebaseUser': userCredential.user};
        }
      }
      throw Exception(
        'Invalid credentials or unexpected response: ${response.statusCode}',
      );
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

      // Create user document in Firestore
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
