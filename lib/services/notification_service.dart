import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:probeauty_app/services/api_client.dart';

class NotificationService {
  static Future<void> registerDevice() async {
    try {
      // Ask permission
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      // Send to backend using ApiClient (auto token + retry + timeout)
      await ApiClient.post(
        "/api/v1/notifications/register-token",
        body: {
          "token": fcmToken,
          "platform": Platform.isAndroid ? "android" : "ios",
        },
      );
    } catch (e) {
      debugPrint("Notification register failed: $e");
    }
  }
}
