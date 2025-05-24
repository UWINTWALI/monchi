import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'upgrade_plan_page.dart';
import 'get_started_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.primaryColor, // Use your defined pink or fallback color
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Top image (replace with your asset path)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main rectangular image
                  Image.asset(
                    'assets/images/monchi_avatar.png',
                    height: 350,
                    width: 350,
                    fit: BoxFit.cover,
                  ),

                  // Faded edge overlay
                  Container(
                    height: 350,
                    width: 350,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: [0.0, 0.15, 0.85, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    height: 350,
                    width: 350,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: [0.0, 0.15, 0.85, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome to Mochi',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Psst… Mochi’s here. Talk to me like we’ve known each other forever.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate or skip
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GetStartedPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.pinkAccent),
                          ),
                          child: const Text("Skip"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to next screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpgradePlanPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          child: const Text("Continue"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
