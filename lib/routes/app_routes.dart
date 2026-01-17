import 'package:flutter/material.dart';
import 'package:probeauty_app/models/product.dart';

import 'package:probeauty_app/pages/appointments_screen.dart';
import 'package:probeauty_app/pages/cart_screen.dart';
import 'package:probeauty_app/pages/decision_screen.dart';
import 'package:probeauty_app/pages/favourites_screen.dart';
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

  // Central route handler
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case decision:
        return _page(const DecisionScreen());

      case login:
        return _page(const LoginScreen());

      case signup:
        return _page(const SignupScreen());

      case otp:
        return _page(const OTPScreen());

      case main:
        return _page(const MainScreen());

      case onboarding:
        return _page(const OnboardingScreen());

      case notification:
        return _page(const NotificationScreen());

      case notificationSettings:
        return _page(const NotificationSettings());

      case appointments:
        return _page(const AppointmentsScreen());

      case profileDetails:
        return _page(const ProfileDetails());

      case savedAddress:
        return _page(const SavedAddressScreen());

      case cart:
        return _page(const CartScreen());

      case orders:
        return _page(const OrdersScreen());

      case favourites:
        return _page(const FavouritesScreen());

      case product:
        final args = settings.arguments as Map<String, dynamic>;

        final Product product = args["product"];
        final String salonName = args["salonName"];

        return _page(
          ProductScreen(
            product: product,
            salonName: salonName,
          ),
        );

      default:
        return _page(const MainScreen());
    }
  }

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
