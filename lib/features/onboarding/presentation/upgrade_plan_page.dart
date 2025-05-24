import 'package:flutter/material.dart';
import 'get_started_page.dart';

class UpgradePlanPage extends StatelessWidget {
  const UpgradePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4081), // Pink background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Top image of phone or plan (you can use a placeholder image here)
            Center(
              child: Image.asset(
                'assets/images/premium.png', // Replace with your actual image
                height: 300,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Unlock Premium, Explore More Benefits",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Unlock Deeper Connection   With monchi, Experience an emotionally intelligent AI companion who understands and grow with you on a deeper level.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const Spacer(),
                    // Skip button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Handle skip logic or navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GetStartedPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Let's get started button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle upgrade logic or navigation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Let's Get Started",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
