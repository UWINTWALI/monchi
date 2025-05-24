import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/input_field.dart';
import '../data/auth_repository.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Login to your account and continue connecting hearts.",
              ),
              const SizedBox(height: 30),

              InputField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              InputField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: "Sign in", onPressed: _signIn),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/sign-up");
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ),
              ),

              const Divider(height: 32),
              const Center(child: Text("or continue with")),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  socialIconButton("G"),
                  socialIconButton(""),
                  socialIconButton("f"),
                  socialIconButton("X"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      final user = await _authRepository.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // Successfully signed in
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        // This should not happen, but just in case
        throw Exception('Failed to sign in. Please try again.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget socialIconButton(String label) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
