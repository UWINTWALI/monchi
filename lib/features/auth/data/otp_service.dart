// import 'dart:math';
// import 'package:shared_preferences/shared_preferences.dart';

// class OTPService {
//   static const _otpKey = 'password_reset_otp';
//   static const _emailKey = 'reset_email';
//   static const _expiryKey = 'otp_expiry';
  
//   Future<String> generateOTP() {
//     final random = Random();
//     final otp = List.generate(6, (_) => random.nextInt(10)).join();
//     return Future.value(otp);
//   }

//   Future<void> saveOTP(String email, String otp) async {
//     final prefs = await SharedPreferences.getInstance();
//     final expiry = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;
    
//     await prefs.setString(_otpKey, otp);
//     await prefs.setString(_emailKey, email);
//     await prefs.setInt(_expiryKey, expiry);
//   }

//   Future<bool> verifyOTP(String email, String otp) async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedOTP = prefs.getString(_otpKey);
//     final savedEmail = prefs.getString(_emailKey);
//     final expiry = prefs.getInt(_expiryKey);

//     if (savedOTP == null || savedEmail == null || expiry == null) {
//       return false;
//     }

//     if (DateTime.now().millisecondsSinceEpoch > expiry) {
//       await _clearOTP();
//       throw Exception('OTP has expired');
//     }

//     if (email != savedEmail) {
//       return false;
//     }

//     if (otp != savedOTP) {
//       return false;
//     }

//     return true;
//   }

//   Future<void> _clearOTP() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_otpKey);
//     await prefs.remove(_emailKey);
//     await prefs.remove(_expiryKey);
//   }
// }