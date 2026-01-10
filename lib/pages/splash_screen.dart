import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../resources/AppColors.dart';
import 'decision_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // bool _moveUp = false; //
  late final AnimationController _lottieController;

  static const double startProgress = 0.0;
  static const double endProgress = 0.35;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  /// 🔐 SESSION CHECK
  Future<void> _decideNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("accessToken");

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            (accessToken != null && accessToken.isNotEmpty)
                ? const MainScreen()
                : const DecisionScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _afterPartialAnimation() {
    Future.delayed(const Duration(milliseconds: 1), () {
      if (!mounted) return;

      // ❌ Logo movement disabled
      // setState(() => _moveUp = true);

      Future.delayed(const Duration(milliseconds: 700), _decideNextScreen);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
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

          // ❌ Fixed at center, no movement
          // alignment: _moveUp ? const Alignment(0, -0.70) : Alignment.center,
          alignment: Alignment.center,

          child: SizedBox(
            width: size.width * 0.9,
            height: size.width * 0.9,
            child: Lottie.asset(
              'assets/lottie/probeauty_logo.json',
              controller: _lottieController,
              repeat: false,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;

                /// jump to start
                _lottieController.value = startProgress;

                /// play only the required segment
                _lottieController
                    .animateTo(
                      endProgress,
                      duration:
                          composition.duration * (endProgress - startProgress),
                      curve: Curves.linear,
                    )
                    .then((_) => _afterPartialAnimation());
              },
            ),
          ),
        ),
      ),
    );
  }
}
