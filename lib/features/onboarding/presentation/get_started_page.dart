import 'package:flutter/material.dart';
import '../../../features/auth/presentation/signup_page.dart';
import '../../../features/auth/presentation/signin_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // App logo or icon
              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 48),
              const SizedBox(height: 20),
              const Text(
                "Let's Get Started!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let’s dive in into your account",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Social login buttons
              socialButton('Continue with Google', Icons.g_mobiledata),
              socialButton('Continue with Apple', Icons.apple),
              socialButton('Continue with Facebook', Icons.facebook),
              socialButton('Continue with X', Icons.close),

              const SizedBox(height: 20),

              // Sign up button
              ElevatedButton(
                onPressed: () {
                  // Handle Sign Up navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Sign up"),
              ),
              const SizedBox(height: 10),

              // Sign in button
              OutlinedButton(
                onPressed: () {
                  // Handle Sign In navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SigninPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.pinkAccent),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Sign in",
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Privacy Policy",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Text("•", style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 8),
                  Text(
                    "Terms of Service",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        onPressed: () {
          // Handle social login
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
