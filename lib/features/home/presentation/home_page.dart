import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
// import '../../dashboard/presentation/emotion_dashboard_page.dart';
// import '../../profile/presentation/profile_page.dart';
// import '../../about/about_page.dart';
// import '../../feedback/ai_feedback_page.dart';
// import 'package:monchi_ai_companion_app/features/dashboard/presentation/emotion_dashboard_page.dart';
// import 'package:monchi_ai_companion_app/features/profile/profile_page.dart';
// import 'package:monchi_ai_companion_app/features/about/about_page.dart';
// import 'package:monchi_ai_companion_app/features/feedback/ai_feedback_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: const AppDrawer(),
      body: const _MainHomeBody(),
    );
  }
}

class _MainHomeBody extends StatelessWidget {
  const _MainHomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          const Text(
            'Hey [UserName], I missed you :-)!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Mochi Avatar
          Center(
            child: GestureDetector(
              onTap: () {
                // Interact with Mochi
              },
              child: ClipOval(
                child: Image.asset(
                  'assets/images/monchi_avatar.png',
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover, // Ensures image fills the circle
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Emotion Check-in
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _emojiButton('😊'),
                      _emojiButton('😔'),
                      _emojiButton('😠'),
                      _emojiButton('😴'),
                      _emojiButton('🤩'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to detailed emotion input
                      },
                      child: const Text('Tell Mochi More'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mood Summary
          const Text(
            'You\'ve been feeling joyful lately, keep it up!',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),

          // Chat Button
          // Center(
          //   child: ElevatedButton.icon(
          //     icon: const Icon(Icons.chat_bubble_outline),
          //     label: const Text('Talk to Mochi'),
          //     onPressed: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
          //     },
          //   ),
          // ),
          const SizedBox(height: 20),

          // Affirmation
          const Text(
            'You deserve love, even from yourself.',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Emotional Analytics
          const Text(
            'This week\'s mood: 🌈 60% Joy · 30% Calm · 10% Frustration',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget _emojiButton(String emoji) {
    return IconButton(
      onPressed: () {
        // Track emoji feedback
      },
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}
