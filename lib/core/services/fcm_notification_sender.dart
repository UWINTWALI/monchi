// A helper class for sending Firebase Cloud Messaging (FCM) notifications
// This would typically be used on your backend server
// See https://firebase.google.com/docs/cloud-messaging/server for implementation details

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// This class demonstrates how FCM notifications can be sent from your server
/// In a real application, you would implement this on your backend server
class FcmNotificationSender {
  // Your Firebase server key should be kept secret on your server
  // This is just for demonstration purposes
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  /// Send notification to a specific device using FCM token
  static Future<bool> sendNotificationToDevice({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      final payload = {
        'notification': {'title': title, 'body': body, 'sound': 'default'},
        'data': data ?? {},
        'to': fcmToken,
        'priority': 'high',
      };

      if (kDebugMode) {
        print('Sending FCM notification to token: $fcmToken');
        print('Payload: ${jsonEncode(payload)}');
      }

      // In a real application, this would be done on your server
      // NOT in the Flutter app!
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('FCM Response: ${response.statusCode}');
        print('FCM Response Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM notification: $e');
      }
      return false;
    }
  }

  /// Send notification to a topic
  static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      final payload = {
        'notification': {'title': title, 'body': body, 'sound': 'default'},
        'data': data ?? {},
        'to': '/topics/$topic',
        'priority': 'high',
      };

      if (kDebugMode) {
        print('Sending FCM notification to topic: $topic');
      }

      // In a real application, this would be done on your server
      // NOT in the Flutter app!
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM notification to topic: $e');
      }
      return false;
    }
  }

  /// Send notification to multiple devices
  static Future<bool> sendNotificationToMultipleDevices({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      final payload = {
        'notification': {'title': title, 'body': body, 'sound': 'default'},
        'data': data ?? {},
        'registration_ids': fcmTokens,
        'priority': 'high',
      };

      if (kDebugMode) {
        print('Sending FCM notification to ${fcmTokens.length} devices');
      }

      // In a real application, this would be done on your server
      // NOT in the Flutter app!
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM notifications: $e');
      }
      return false;
    }
  }
}
