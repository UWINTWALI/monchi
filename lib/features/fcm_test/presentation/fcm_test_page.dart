import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // For clipboard functionality
import '../../../core/services/fcm_helper.dart';

class FCMTestPage extends StatefulWidget {
  const FCMTestPage({super.key});

  @override
  State<FCMTestPage> createState() => _FCMTestPageState();
}

class _FCMTestPageState extends State<FCMTestPage> {
  String? _fcmToken;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize FCM Helper
      await FCMHelper.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing FCM: $e';
      });
      print('❌ Error initializing FCM: $e');
    }
  }

  Future<void> _getFCMToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await FCMHelper.getToken();
      setState(() {
        _fcmToken = token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting FCM token: $e';
      });
      print('❌ Error getting FCM token: $e');
    }
  }
  Future<void> _showTestNotification() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      await FCMHelper.showTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local test notification sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending local notification: $e';
      });
      print('❌ Error sending local notification: $e');
    }
  }
  
  Future<void> _sendFcmNotification() async {
    setState(() {
      _errorMessage = null;
    });
    
    if (_fcmToken == null) {
      setState(() {
        _errorMessage = 'No FCM token available. Get the token first.';
      });
      return;
    }

    try {
      final result = await FCMHelper.sendFcmNotification(
        fcmToken: _fcmToken!,
        title: 'FCM Test Notification',
        body: 'This is a test FCM notification from Monchi App',
        data: {'test': 'true', 'timestamp': DateTime.now().toIso8601String()},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result 
            ? 'FCM notification sent successfully' 
            : 'FCM notification failed to send'),
          backgroundColor: result ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending FCM notification: $e';
      });
      print('❌ Error sending FCM notification: $e');
    }
  }

  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM token copied to clipboard'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Cloud Messaging Test Page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Error message display
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // FCM token display
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FCM Token:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_fcmToken != null)
                    Text(
                      _fcmToken!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    )
                  else
                    const Text(
                      'No token available. Click "Get FCM Token" button.',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),            // Action buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _getFCMToken,
                      child: const Text('Get FCM Token'),
                    ),
                    ElevatedButton(
                      onPressed: _fcmToken == null ? null : _copyTokenToClipboard,
                      child: const Text('Copy Token'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _showTestNotification,
                      child: const Text('Local Notification'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading || _fcmToken == null ? null : _sendFcmNotification,
                      child: const Text('FCM Notification'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Instructions
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),            const Text(
              '1. Click "Get FCM Token" to retrieve your device token\n'
              '2. Click "Copy Token" to copy it to the clipboard\n'
              '3. Click "Local Notification" to show a local test notification\n'
              '4. Click "FCM Notification" to test sending a cloud message to your device\n'
              '5. For Firebase Console testing: go to Firebase Console > Cloud Messaging and use the token',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


