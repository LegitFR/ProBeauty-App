import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/appointments_screen.dart';
import 'package:probeauty_app/pages/explore_screen.dart';
import 'package:probeauty_app/pages/home_screen.dart';
import 'package:probeauty_app/pages/profile_screen.dart';
import 'package:probeauty_app/pages/shop_screen.dart';
import 'package:probeauty_app/pages/status_bar_wrapper.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // 🔔 When user taps notification (background → open app)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 Notification tapped");
      _handleNotificationTap(message.data);
    });

    // 🔔 App opened from terminated state via notification
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      debugPrint("🚀 App opened from terminated via notification");
      _handleNotificationTap(message.data);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'];

    if (screen == 'BookingDetails') {
      if (!mounted) return;
      Navigator.pushNamed(context, '/bookingDetails');
    } else if (screen == 'OrderDetails') {
      if (!mounted) return;
      Navigator.pushNamed(context, '/orderDetails');
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    ShopScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  final List<String> _iconPaths = [
    'assets/images/icons/home_icon.svg',
    'assets/images/icons/search_icon.svg',
    'assets/images/icons/cart_icon.svg',
    'assets/images/icons/location_icon.svg',
    'assets/images/icons/profile_icon.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> labels = [
      l10n.bottomNavHome,
      l10n.bottomNavExplore,
      l10n.bottomNavShop,
      l10n.bottomNavAppointments,
      l10n.bottomNavProfile,
    ];
    return StatusBarWrapper(
      child: Scaffold(
        extendBody: true,
        body: _screens[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CurvedNavigationBar(
                backgroundColor: AppColors.softIvory,
                color: AppColors.softIvory2,
                buttonBackgroundColor: AppColors.rusticSunset,
                height: 70,
                index: _selectedIndex,
                items: List.generate(_iconPaths.length, (index) {
                  bool isSelected = index == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      _iconPaths[index],
                      height: isSelected ? 25 : 22,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : Colors.black87,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                }),
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                onTap: (index) {
                  if (_selectedIndex == index) return;

                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              Positioned(
                bottom: 7,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(labels.length, (index) {
                    bool isSelected = index == _selectedIndex;
                    return Expanded(
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Text(
                                  labels[index],
                                  maxLines: 1, // ✅ force single line
                                  overflow: TextOverflow.ellipsis, // ✅ show ...
                                  softWrap: false,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.rusticSunset,
                                    fontFamily: "PoppinsRegular",
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
