import 'package:flutter/material.dart';
import 'chat_input.dart';
import 'chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> messages = [
    {'sender': 'Mochi', 'text': 'Hi honey, how was your day? 💖'},
    {'sender': 'You', 'text': 'Hey Mochi! It was a bit stressful 😥'},
    {'sender': 'Mochi', 'text': 'Aww I’m here for you, always 💕'},
  ];

  void sendMessage(String message) {
    setState(() {
      messages.add({'sender': 'You', 'text': message});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCEFF9),
      appBar: AppBar(
        title: Text('Mochi 💌'),
        backgroundColor: Color(0xFFEFB4D5),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  text: message['text']!,
                  isMe: message['sender'] == 'You',
                );
              },
            ),
          ),
          ChatInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
