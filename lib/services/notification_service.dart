import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/config/api_config.dart';

class NotificationService {
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
      Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/register-token'),
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
