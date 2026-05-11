import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/services/api_client.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> signInWithGoogle() async {
    try {
      debugPrint("STEP 1: Signing out previous session");

      await _googleSignIn.signOut();
      await _auth.signOut();

      debugPrint("STEP 2: Starting Google sign in");

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      debugPrint("STEP 3: Account response = $account");

      if (account == null) {
        debugPrint("ERROR: User cancelled sign in");
        return false;
      }

      debugPrint("STEP 4: Getting authentication");

      final GoogleSignInAuthentication auth = await account.authentication;

      debugPrint("ACCESS TOKEN = ${auth.accessToken}");
      debugPrint("ID TOKEN = ${auth.idToken}");

      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      if (idToken == null) {
        debugPrint("ERROR: Google ID token is null");
        throw Exception("Google ID token missing");
      }

      // ---------------- FIREBASE AUTH ----------------

      debugPrint("STEP 5: Signing into Firebase");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint(
        "FIREBASE LOGIN SUCCESS = ${userCredential.user?.email}",
      );

      // ---------------- BACKEND LOGIN ----------------

      debugPrint("STEP 6: Sending token to backend");

      final response = await ApiClient.post(
        "/api/v1/auth/google",
        body: {
          "idToken": idToken,
        },
      );

      debugPrint(
        "BACKEND STATUS CODE = ${response.statusCode}",
      );

      debugPrint(
        "BACKEND RESPONSE = ${response.body}",
      );

      final Map<String, dynamic> data =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("STEP 7: Saving user session");

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          "accessToken",
          data["accessToken"],
        );

        await prefs.setString(
          "refreshToken",
          data["refreshToken"],
        );

        if (data["user"] != null) {
          await prefs.setString(
            "userId",
            data["user"]["id"],
          );

          await prefs.setString(
            "userName",
            data["user"]["name"],
          );

          await prefs.setString(
            "userEmail",
            data["user"]["email"],
          );

          if (data["user"]["phone"] != null) {
            await prefs.setString(
              "userPhone",
              data["user"]["phone"],
            );
          }
        }

        debugPrint("GOOGLE LOGIN FULL SUCCESS");

        return true;
      } else {
        debugPrint("ERROR: Backend rejected login");

        // Optional cleanup
        await _auth.signOut();
        await _googleSignIn.signOut();

        return false;
      }
    } catch (e, stacktrace) {
      debugPrint("GOOGLE SIGN IN ERROR = $e");

      debugPrint("STACKTRACE = $stacktrace");

      return false;
    }
  }
}
