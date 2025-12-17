import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/pages/appointments_screen.dart';
import 'package:probeauty_app/pages/explore_screen.dart';
import 'package:probeauty_app/pages/home_screen.dart';
import 'package:probeauty_app/pages/profile_screen.dart';
import 'package:probeauty_app/pages/shop_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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

  final List<String> _labels = const [
    'My Precut',
    'Explore',
    'Shop',
    'Appointments',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        bottom: true,
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
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            // Label for selected item
            Positioned(
              bottom: 7,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_labels.length, (index) {
                  bool isSelected = index == _selectedIndex;
                  return Expanded(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: isSelected
                            ? Text(
                                _labels[index],
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
    );
  }
}
