import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _fcmTokenKey = 'fcm_token';
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission for notifications (required for iOS)
    await _requestNotificationPermission();

    // Setup notification channels for Android
    await _setupNotificationChannels();

    // Setup foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token
    await getFcmToken();

    // Setup token refresh listener
    _messaging.onTokenRefresh.listen((token) {
      _saveFcmToken(token);
      if (kDebugMode) {
        print('FCM Token refreshed: $token');
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle messages received when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print(
        'User notification permission status: ${settings.authorizationStatus}',
      );
    }
  }

  static Future<void> _setupNotificationChannels() async {
    // Only needed for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Initialize local notification plugin
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  static Future<String?> getFcmToken() async {
    try {
      // Check if we already have a saved token
      final prefs = await SharedPreferences.getInstance();
      String? existingToken = prefs.getString(_fcmTokenKey);

      // If no saved token or force refresh, get a new one from Firebase
      if (existingToken == null) {
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveFcmToken(token);
          existingToken = token;
        }
      }

      if (kDebugMode && existingToken != null) {
        print('FCM Token: $existingToken');
      }

      return existingToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  static Future<void> deleteFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      await _messaging.deleteToken();
      if (kDebugMode) {
        print('FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }

  // Handle background messages
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print('Handling background message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
    }

    // You can implement custom logic here for handling background messages
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Got a message in the foreground!');
      print('Message data: ${message.data}');
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Show local notification for foreground messages
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: android.smallIcon,
            channelDescription:
                'This channel is used for important notifications.',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Subscribe to a topic for targeted notifications
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  // Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }
}
