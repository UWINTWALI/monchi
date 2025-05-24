import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add currentUser getter
  User? get currentUser => _auth.currentUser;

  // Add token getter
  Future<String> get token async => await currentUser?.getIdToken() ?? '';

  // Add method to check auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user's email
  String? get userEmail => currentUser?.email;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      email = email.trim().toLowerCase();
      String otp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();

      await _firestore.collection('otps').doc(email).set({
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 15)),
        ),
      });

      if (kIsWeb) {
        // For web platform, use Firebase's built-in password reset
        await _auth.sendPasswordResetEmail(email: email);
        print('Password reset email sent via Firebase');
      } else {
        // For mobile platforms, use custom SMTP (implement separately)
        throw UnimplementedError('Mobile implementation needed');
      }
    } catch (e) {
      print('Error in sendPasswordResetEmail: $e');
      throw Exception('Failed to process password reset: $e');
    }
  }

  Future<bool> verifyOTP(String email, String providedOtp) async {
    try {
      final otpDoc = await _firestore.collection('otps').doc(email).get();

      if (!otpDoc.exists) {
        throw Exception('No OTP found for this email');
      }

      final data = otpDoc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = data['expiresAt'] as Timestamp;

      if (DateTime.now().isAfter(expiresAt.toDate())) {
        await otpDoc.reference.delete();
        throw Exception('OTP has expired');
      }

      if (storedOtp != providedOtp) {
        throw Exception('Invalid OTP');
      }

      // Clean up used OTP
      await otpDoc.reference.delete();
      return true;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<void> resetPassword(String otp, String newPassword) async {
    try {
      // Get current user's email from Firebase Auth
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Verify the OTP one last time
      final otpDoc = await _firestore
          .collection('otps')
          .doc(currentUser.email)
          .get();

      if (!otpDoc.exists) {
        throw Exception('Invalid or expired OTP');
      }

      final data = otpDoc.data()!;
      if (data['otp'] != otp) {
        throw Exception('Invalid OTP');
      }

      // Update the password
      await currentUser.updatePassword(newPassword);

      // Clean up the OTP document
      await otpDoc.reference.delete();

      // Sign out the user to force re-authentication with new password
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}
