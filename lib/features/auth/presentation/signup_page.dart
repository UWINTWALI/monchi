import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/input_field.dart';
import '../data/auth_repository.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agree = false;
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
                "Join monchi Today!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create your account and start vibing with monchi today!",
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

              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    activeColor: Colors.pinkAccent,
                    onChanged: (val) => setState(() => _agree = val!),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "I agree to Monchi's ",
                        children: [
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                  : CustomButton(text: "Sign up", onPressed: _signUp),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/log-in");
                  },
                  child: const Text(
                    "Already have an account? Sign in",
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

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (!_agree) {
        throw Exception('Please agree to the Terms & Conditions');
      }

      final user = await _authRepository.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // Successfully signed up, navigate to login or main screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
          // Alternatively: Navigator.pushReplacementNamed(context, '/log-in');
        }
      } else {
        // This should not happen, but just in case
        throw Exception('Failed to sign up. Please try again.');
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
