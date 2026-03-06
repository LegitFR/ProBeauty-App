import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import "package:flutter/material.dart";
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:probeauty_app/app_locale.dart';
import 'package:probeauty_app/firebase_options.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/splash_screen.dart';
import 'package:probeauty_app/providers/address_provider.dart';
import 'package:probeauty_app/providers/appointment_provider.dart';
import 'package:probeauty_app/providers/cart_provider.dart';
import 'package:probeauty_app/providers/explore_provider.dart';
import 'package:probeauty_app/providers/offers_provider.dart';
import 'package:probeauty_app/providers/order_provider.dart';
import 'package:probeauty_app/providers/product_provider.dart';
import 'package:probeauty_app/providers/salon_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:probeauty_app/routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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
  await dotenv.load(fileName: "assets/.env"); //

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('languageCode') ?? 'en';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'default',
          'Default Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  });

  await requestNotificationPermission();
  await setupNotificationChannel();
  await initializeLocalNotifications();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
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
      theme: ThemeData(
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.rusticSunset,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.transparent,
          selectionColor: Color.fromARGB(255, 252, 138, 89),
          cursorColor: AppColors.rusticSunset,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.softIvory,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: "PoppinsSemiBold",
            fontSize: 18,
          ),
        ),
      ),
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
      onGenerateRoute: AppRoutes.generate,
    );
  }
}
