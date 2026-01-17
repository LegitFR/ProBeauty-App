import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _baseUrl =
      'https://probeauty-backend.onrender.com/api/v1';

  static Future<void> registerDevice(String jwt) async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      return;
    }

    // Send token to backend
    await http.post(
      Uri.parse('$_baseUrl/notifications/register-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        'token': fcmToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      }),
    );
  }
}
