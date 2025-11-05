import 'dart:async';
import 'package:flutter/material.dart';
import '../resources/AppColors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _controller;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 🎞 Total animation duration for full splash (matches total frames)
    const totalDuration = Duration(milliseconds: 3850);
    _controller = AnimationController(vsync: this, duration: totalDuration);

    // ⏱ Automatically calculate frame change interval
    final frameInterval = Duration(
      milliseconds: (totalDuration.inMilliseconds / _images.length).round(),
    );

    // 🌀 Change frame at fixed intervals (no looping)
    _imageTimer = Timer.periodic(frameInterval, (timer) {
      setState(() {
        if (_currentIndex < _images.length - 1) {
          _currentIndex++;
        } else {
          _imageTimer?.cancel();
        }
      });
    });

    // 🎬 Start movement + scale animation
    _controller.forward();

    // 🚀 Move to next screen after animation completes
    Future.delayed(totalDuration + const Duration(milliseconds: 250), () {
      _imageTimer?.cancel();
      Navigator.pushReplacementNamed(context, '/decision');
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    _moveUpAnimation = Tween<double>(
      begin: 0.0,
      end: -screenHeight * 0.45, // Move towards top
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.4, // Shrink to 40%
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    return Scaffold(
      backgroundColor: AppColors.rusticSunset,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Transform.translate(
              offset: Offset(0, _moveUpAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Image.asset(
                    _images[_currentIndex],
                    key: ValueKey<String>(_images[_currentIndex]),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
