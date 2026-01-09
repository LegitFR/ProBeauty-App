import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import "package:flutter/material.dart";
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:probeauty_app/app_locale.dart';
import 'package:probeauty_app/firebase_options.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/favourites_screen.dart';
import 'package:probeauty_app/pages/ordersScreen.dart';
import 'package:probeauty_app/pages/appointment_info.dart';
import 'package:probeauty_app/pages/cart_screen.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/pages/login_screen.dart';
import 'package:probeauty_app/pages/notification_settings.dart';
import 'package:probeauty_app/pages/onboarding_screen.dart';
import 'package:probeauty_app/pages/otp_screen.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/pages/profile_details.dart';
import 'package:probeauty_app/pages/saved_address_screen.dart';
import 'package:probeauty_app/pages/signup_screen.dart';
import 'package:probeauty_app/pages/splash_screen.dart';
import 'package:probeauty_app/providers/cart_provider.dart';
import 'package:probeauty_app/providers/order_provider.dart';
import 'package:probeauty_app/providers/product_provider.dart';
import 'package:probeauty_app/providers/salon_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/appointments_screen.dart';
import 'pages/decision_screen.dart';
import 'pages/notification_screen.dart';
import 'models/product.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔕 Background message received: ${message.data}");
}

Future<void> requestNotificationPermission() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default',
    'Default Notifications',
    description: 'General notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('languageCode') ?? 'en';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestNotificationPermission();
  await setupNotificationChannel();
  await initializeLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Stripe.publishableKey =
      'pk_test_51SSLPXFg60Wha3A5QhjKRseEZTKPkpEIfQdfGp0p2TKi7ScL6CSbJmsQUB6VzDwpZsN9foPJfmFZYVq5Z9JSX2I700VsaiuHRe';
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AppLocale(code)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final appLocale = context.watch<AppLocale>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: appLocale.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
        Locale('fr'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),

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
          case '/notification_setting':
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
          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());
          case '/orders':
            return MaterialPageRoute(builder: (_) => const OrdersScreen());
          case "/favourites":
            return MaterialPageRoute(builder: (_) => const FavouritesScreen());
        }

        // Fallback: main screen
        return MaterialPageRoute(builder: (_) => const MainScreen());
      },
    );
  }
}
