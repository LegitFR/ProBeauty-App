import "package:flutter/material.dart";
import 'package:probeauty_app/pages/appointment_info.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/pages/login_screen.dart';
import 'package:probeauty_app/pages/notification_settings.dart';
import 'package:probeauty_app/pages/onboarding_screen.dart';
import 'package:probeauty_app/pages/otp_screen.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/pages/profile_details.dart';
import 'package:probeauty_app/pages/profile_screen.dart';
import 'package:probeauty_app/pages/saved_address_screen.dart';
import 'package:probeauty_app/pages/signup_screen.dart';
import 'package:probeauty_app/pages/splash_screen.dart';
import 'pages/appointments_screen.dart';
import 'pages/decision_screen.dart';
import 'pages/notification_screen.dart';
import 'models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),

      // ------------- FIXED: onGenerateRoute for passing arguments -------------
      onGenerateRoute: (settings) {
        if (settings.name == '/product_screen') {
          final args = settings.arguments as Map<String, dynamic>;

          final Product product = args["product"];
          final String salonName = args["salonName"];

          return MaterialPageRoute(
            builder: (_) => ProductScreen(
              product: product,
              salonName: salonName,
            ),
          );
        }

        // default routes
        switch (settings.name) {
          case '/decision':
            return MaterialPageRoute(builder: (_) => const DecisionScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/OTP':
            return MaterialPageRoute(builder: (_) => const OTPScreen());
          case '/main':
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/notification':
            return MaterialPageRoute(
                builder: (_) => const NotificationScreen());
          case '/notification_settings':
            return MaterialPageRoute(
                builder: (_) => const NotificationSettings());
          case '/appointments':
            return MaterialPageRoute(
                builder: (_) => const AppointmentsScreen());
          case '/appointment_info':
            return MaterialPageRoute(builder: (_) => const AppointmentInfo());
          case '/profile_details':
            return MaterialPageRoute(builder: (_) => const ProfileDetails());
          case '/saved_address':
            return MaterialPageRoute(
                builder: (_) => const SavedAddressScreen());
        }

        // Fallback: main screen
        return MaterialPageRoute(builder: (_) => const MainScreen());
      },
    );
  }
}
