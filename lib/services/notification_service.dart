import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _baseUrl =
      'https://probeauty-backend.onrender.com/api/v1';

  static Future<void> registerDevice(String jwt) async {
    // Ask permission (Android 13+, iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print('⚠️ FCM token is null');
      return;
    }

    print('📱 FCM Token: $fcmToken');

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
