import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/services/api_client.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  static Future<void> signInWithGoogle() async {
    try {
      // Force fresh session
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception("Google ID token missing");
      }

      final response = await ApiClient.post(
        "/api/v1/auth/google",
        body: {
          "idToken": idToken,
        },
      );

      final Map<String, dynamic> data =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("accessToken", data["accessToken"]);
        await prefs.setString("refreshToken", data["refreshToken"]);

        if (data["user"] != null) {
          await prefs.setString("userId", data["user"]["id"]);
          await prefs.setString("userName", data["user"]["name"]);
          await prefs.setString("userEmail", data["user"]["email"]);

          if (data["user"]["phone"] != null) {
            await prefs.setString("userPhone", data["user"]["phone"]);
          }
        }
      } else {
        throw Exception(data["message"] ?? "Google login failed");
      }
    } catch (e) {
      debugPrint("Google sign-in failed: $e");
      rethrow;
    }
  }
}
