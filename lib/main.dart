import "package:flutter/material.dart";
import 'package:probeauty_app/pages/appointment_info.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/pages/login_screen.dart';
import 'package:probeauty_app/pages/notification_settings.dart';
import 'package:probeauty_app/pages/onboarding_screen.dart';
import 'package:probeauty_app/pages/otp_screen.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/pages/profile_details.dart';
import 'package:probeauty_app/pages/signup_screen.dart';
import 'package:probeauty_app/pages/splash_screen.dart';
import 'pages/appointments_screen.dart';
import 'pages/decision_screen.dart';
import 'pages/notification_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/decision': (context) => const DecisionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/OTP': (context) => const OTPScreen(),
        '/main': (context) => const MainScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/notification_settings': (context) => const NotificationSettings(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/appointment_info': (context) => const AppointmentInfo(),
        '/profile_details': (context) => const ProfileDetails(),
        '/product_screen': (context) => const ProductScreen(),
      },
    );
  }
}
