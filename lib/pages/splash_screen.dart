import 'dart:async';
import 'package:flutter/material.dart';
import '../resources/AppColors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _images = [
    'assets/images/splash/Frame 4-6.png',
    'assets/images/splash/Frame 4-5.png',
    'assets/images/splash/Frame 4-4.png',
    'assets/images/splash/Frame 4-3.png',
    'assets/images/splash/Frame 4-2.png',
    'assets/images/splash/Frame 4-1.png',
    'assets/images/splash/Frame 4.png',
  ];

  int _currentIndex = 0;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();

    // Total duration for smooth transition
    const totalDuration = Duration(milliseconds: 3500);

    // Smoothly calculated frame duration
    final frameInterval = Duration(
      milliseconds: (totalDuration.inMilliseconds / _images.length).round(),
    );

    // Change frames smoothly
    _imageTimer = Timer.periodic(frameInterval, (timer) {
      if (_currentIndex < _images.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _imageTimer?.cancel();
      }
    });

    // Go to next screen after all frames are shown
    Future.delayed(totalDuration + const Duration(milliseconds: 400), () {
      Navigator.pushReplacementNamed(context, '/decision');
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.rusticSunset,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Image.asset(
            _images[_currentIndex],
            key: ValueKey<String>(_images[_currentIndex]),
            width: 220,
            height: 220,
          ),
        ),
      ),
    );
  }
}
