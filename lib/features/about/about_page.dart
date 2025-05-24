import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Mochi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/monchi_avatar.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What is Mochi?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mochi is your personal AI companion designed to help you navigate your emotional journey. '
              'Through daily conversations and check-ins, Mochi helps you understand and manage your emotions better.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeature(
              icon: Icons.chat_bubble_outline,
              title: 'Emotional Support',
              description:
                  'Have meaningful conversations about your feelings and experiences.',
            ),
            _buildFeature(
              icon: Icons.analytics_outlined,
              title: 'Mood Tracking',
              description:
                  'Track your emotional patterns and progress over time.',
            ),
            _buildFeature(
              icon: Icons.psychology_outlined,
              title: 'Personalized Insights',
              description:
                  'Receive tailored suggestions and insights based on your interactions.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Version',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1.0.0', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
