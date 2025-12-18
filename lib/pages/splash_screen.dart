import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/AppColors.dart';
import 'decision_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _images = [
    'assets/images/splash/0.png',
    'assets/images/splash/0.png',
    'assets/images/splash/0.png',
    'assets/images/splash/1.png',
    'assets/images/splash/1.png',
    'assets/images/splash/1.png',
    'assets/images/splash/2.png',
    'assets/images/splash/2.png',
    'assets/images/splash/2.png',
    'assets/images/splash/3.png',
    'assets/images/splash/3.png',
    'assets/images/splash/3.png',
    'assets/images/splash/4.png',
    'assets/images/splash/4.png',
    'assets/images/splash/4.png',
    'assets/images/splash/5.png',
    'assets/images/splash/5.png',
    'assets/images/splash/5.png',
    'assets/images/splash/6.png',
    'assets/images/splash/6.png',
    'assets/images/splash/6.png',
  ];

  int _currentIndex = 0;
  bool _moveUp = false;
  Timer? _imageTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final img in _images) {
      precacheImage(AssetImage(img), context);
    }
  }

  @override
  void initState() {
    super.initState();

    const frameInterval = Duration(milliseconds: 80);

    _imageTimer = Timer.periodic(frameInterval, (timer) {
      if (_currentIndex < _images.length - 1) {
        setState(() => _currentIndex++);
      } else {
        timer.cancel();

        /// ⬆️ Move logo up
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _moveUp = true);
        });

        /// 🔐 Decide next screen
        Future.delayed(const Duration(milliseconds: 900), _decideNextScreen);
      }
    });
  }

  /// 🔐 SESSION CHECK
  Future<void> _decideNextScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString("accessToken");

    if (!mounted) return;

    if (accessToken != null && accessToken.isNotEmpty) {
      // ✅ User already logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // ❌ Not logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DecisionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.rusticSunset,
        body: AnimatedAlign(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          alignment: _moveUp ? const Alignment(0, -0.70) : Alignment.center,
          child: Image.asset(
            _images[_currentIndex],
            width: size.width * 0.35,
            height: size.width * 0.35,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
