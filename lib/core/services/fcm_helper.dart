import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FCMHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM and notification channels
  static Future<void> initialize() async {
    print('🔔 Initializing FCM Helper');

    // Setup notification channels for Android
    await _setupNotificationChannels();

    // Request permission (important for iOS, and newer Android versions)
    await _requestPermission();

    // Set foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    print('✅ FCM Helper initialized successfully');
  }

  /// Request notification permission
  static Future<void> _requestPermission() async {
    print('🔔 Requesting notification permission');

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
        announcement: true,
        carPlay: true,
      );

      print(
        '⚙️ User notification permission status: ${settings.authorizationStatus}',
      );
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Setup notification channels for Android
  static Future<void> _setupNotificationChannels() async {
    print('🔔 Setting up notification channels');

    try {
      // Create the high importance channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      // Create the channel in the system
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('🔔 Notification clicked: ${details.payload}');
        },
      );

      print('✅ Notification channels set up successfully');
    } catch (e) {
      print('❌ Error setting up notification channels: $e');
    }
  }

  /// Get FCM token (with retry logic)
  static Future<String?> getToken() async {
    print('📱 Getting FCM token...');

    // Try multiple times with increasing delay
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final String? token = await _messaging.getToken();

        if (token != null && token.isNotEmpty) {
          print('✅ FCM Token retrieved successfully');
          print('📲 FCM Token: $token');
          return token;
        } else {
          print('⚠️ FCM Token is empty or null (attempt $attempt of 3)');
        }
      } catch (e) {
        print('❌ Error getting FCM token (attempt $attempt of 3): $e');
      }

      // Wait before retrying
      if (attempt < 3) {
        final delay = Duration(seconds: attempt * 2);
        print('⏳ Waiting ${delay.inSeconds} seconds before retry...');
        await Future.delayed(delay);
      }
    }

    print('❌ Failed to get FCM token after 3 attempts');
    return null;
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Got a message in the foreground!');
    print('📩 Message data: ${message.data}');

    if (message.notification != null) {
      print('📩 Message also contained a notification:');
      print('📩 Title: ${message.notification?.title}');
      print('📩 Body: ${message.notification?.body}');

      // Show local notification
      _showLocalNotification(
        title: message.notification?.title ?? 'New notification',
        body: message.notification?.body ?? '',
      );
    }
  }

  /// Show a local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Show a test notification
  static Future<void> showTestNotification() async {
    print('🔔 Showing test notification');
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Monchi App',
    );
  }

  /// Send an FCM notification (for testing purposes only)
  /// WARNING: This should NOT be used in production apps
  /// FCM notifications should be sent from a secure server
  static Future<bool> sendFcmNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // ⚠️ IMPORTANT: This is for TESTING ONLY!
    // In a real app, you should NEVER include your server key in the client app
    // This would typically be on your secure backend server
    const String serverKey = 'YOUR_FIREBASE_SERVER_KEY'; // Replace with your key for testing
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    try {
      print('📤 Attempting to send FCM notification to token: $fcmToken');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final payload = {
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data ?? {},
        'to': fcmToken,
        'priority': 'high',
      };

      // In a real application, this would be done on your server
      // NOT in the Flutter app!
      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📤 FCM Response: ${response.statusCode}');
      print('📤 FCM Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
      return false;
    }
  }
}
