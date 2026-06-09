import 'package:flutter/material.dart';
import 'package:probeauty_app/models/product.dart';

import 'package:probeauty_app/pages/appointments_screen.dart';
import 'package:probeauty_app/pages/cart_screen.dart';
import 'package:probeauty_app/pages/decision_screen.dart';
import 'package:probeauty_app/pages/favourites_screen.dart';
import 'package:probeauty_app/pages/forgot_password_screen.dart';
import 'package:probeauty_app/pages/login_screen.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/pages/notification_screen.dart';
import 'package:probeauty_app/pages/notification_settings.dart';
import 'package:probeauty_app/pages/onboarding_screen.dart';
import 'package:probeauty_app/pages/orders_screen.dart';
import 'package:probeauty_app/pages/otp_screen.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/pages/profile_details.dart';
import 'package:probeauty_app/pages/saved_address_screen.dart';
import 'package:probeauty_app/pages/signup_screen.dart';

class AppRoutes {
  // Route names (typed, no string mess)
  static const decision = '/decision';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/OTP';
  static const main = '/main';
  static const onboarding = '/onboarding';
  static const notification = '/notification';
  static const notificationSettings = '/notification_setting';
  static const appointments = '/appointments';
  static const profileDetails = '/profile_details';
  static const savedAddress = '/saved_address';
  static const cart = '/cart';
  static const orders = '/orders';
  static const favourites = '/favourites';
  static const product = '/product_screen';
  static const forgotpassword = '/forgot_password';

  // Central route handler
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case forgotpassword:
        return _page(const ForgotPasswordScreen(), settings);
      case decision:
        return _page(const DecisionScreen(), settings);

      case login:
        return _page(const LoginScreen(), settings);

      case signup:
        return _page(const SignupScreen(), settings);

      case otp:
        return _page(const OTPScreen(), settings);

      case main:
        return _page(const MainScreen(), settings);

      case onboarding:
        return _page(const OnboardingScreen(), settings);

      case notification:
        return _page(const NotificationScreen(), settings);

      case notificationSettings:
        return _page(const NotificationSettings(), settings);

      case appointments:
        return _page(const AppointmentsScreen(), settings);

      case profileDetails:
        return _page(const ProfileDetails(), settings);

      case savedAddress:
        return _page(const SavedAddressScreen(), settings);

      case cart:
        return _page(const CartScreen(), settings);

      case orders:
        return _page(const OrdersScreen(), settings);

      case favourites:
        return _page(const FavouritesScreen(), settings);

      case product:
        final args = settings.arguments as Map<String, dynamic>;

        final Product product = args["product"];
        final String salonName = args["salonName"];

        return _page(
          ProductScreen(
            product: product,
            salonName: salonName,
          ),
          settings,
        );

      default:
        return _page(const MainScreen(), settings);
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
