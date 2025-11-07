import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:probeauty_app/pages/appointments_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Center(
        child: Text('My precut',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(
        child: Text('Explore',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(
        child: Text('Shop',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    AppointmentsScreen(),
    Center(
        child: Text('Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  final List<IconData> _navIcons = const [
    Icons.home,
    Icons.search,
    Icons.shopping_bag_outlined,
    Icons.location_on_outlined,
    Icons.person_outline,
  ];

  final List<String> _labels = const [
    'My precut',
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
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          CurvedNavigationBar(
            backgroundColor: AppColors.softIvory2,
            color: AppColors.softIvory,
            buttonBackgroundColor: const Color(0xFFFF5722), // Deep orange color
            height: 65, // Reduced height for smaller button
            index: _selectedIndex,
            items: List.generate(_navIcons.length, (index) {
              bool isSelected = index == _selectedIndex;
              return Icon(
                _navIcons[index],
                size: isSelected ? 28 : 25, // Slightly smaller icons
                color: isSelected ? Colors.white : Colors.black,
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
          // Label below the selected item
          Positioned(
            bottom: 9,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navIcons.length, (index) {
                bool isSelected = index == _selectedIndex;
                return Expanded(
                  child: Center(
                    child: isSelected
                        ? Text(
                            _labels[index],
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.rusticSunset,
                                fontFamily: "PoppinsRegular"),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
