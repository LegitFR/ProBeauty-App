import 'dart:async';
import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SplashDecisionScreen extends StatefulWidget {
  const SplashDecisionScreen({super.key});

  @override
  State<SplashDecisionScreen> createState() => _SplashDecisionScreenState();
}

class _SplashDecisionScreenState extends State<SplashDecisionScreen> {
  final List<String> _images = [
    'assets/images/splash/Frame 4-6.png',
    'assets/images/splash/Frame 4-5.png',
    'assets/images/splash/Frame 4-4.png',
    'assets/images/splash/Frame 4-3.png',
    'assets/images/splash/Frame 4-2.png',
    'assets/images/splash/Frame 4-1.png',
    'assets/images/splash/Frame 4.png',
  ];

  int _frameIndex = 0;
  bool _logoUp = false;
  bool _shrinkPanel = false;
  bool _showContent = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (_frameIndex < _images.length - 1) {
        setState(() => _frameIndex++);
      } else {
        timer.cancel();

        Future.delayed(const Duration(milliseconds: 200),
            () => setState(() => _logoUp = true));

        Future.delayed(const Duration(milliseconds: 450),
            () => setState(() => _shrinkPanel = true));

        Future.delayed(const Duration(milliseconds: 900),
            () => setState(() => _showContent = true));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: Column(
        children: [
          // --------------------------------------------------
          // LOGO AREA
          // --------------------------------------------------
          SizedBox(
            height: h * 0.28,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _logoUp
                    ? Image.asset(
                        "assets/images/logos/probeauty_app_logo.png",
                        key: const ValueKey("final"),
                        width: w * 0.45,
                      )
                    : Image.asset(
                        _images[_frameIndex],
                        key: ValueKey(_frameIndex),
                        width: 220,
                      ),
              ),
            ),
          ),

          // --------------------------------------------------
          // ORANGE PANEL AREA (FULL → CARD)
          // --------------------------------------------------
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                width: _shrinkPanel ? w * 0.9 : w,
                height: _shrinkPanel ? h * 0.55 : h,
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.035,
                ),
                decoration: BoxDecoration(
                  color: AppColors.rusticSunset,
                  borderRadius: BorderRadius.circular(_shrinkPanel ? 50 : 0),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showContent ? 1 : 0,
                  child: _DecisionContent(w, h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// DECISION CONTENT (UNCHANGED)
// ===================================================================
class _DecisionContent extends StatelessWidget {
  final double w;
  final double h;
  const _DecisionContent(this.w, this.h);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Hello!",
          style: TextStyle(
            fontSize: w * 0.075,
            color: Colors.white,
            fontFamily: "PlayfairDisplayBold",
          ),
        ),
        SizedBox(height: h * 0.02),
        Text(
          "Create your account or login in to book and manage your appointments.",
          style: TextStyle(
            fontSize: w * 0.035,
            color: Colors.white,
            fontFamily: "PoppinsRegular",
          ),
        ),
        SizedBox(height: h * 0.03),
        Center(
          child: Column(
            children: [
              SizedBox(
                width: w * 0.65,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: w * 0.04,
                      color: AppColors.rusticSunset,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: w * 0.65,
                height: 45,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: w * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: h * 0.04),
        Center(
          child: Text(
            "Sign in with",
            style: TextStyle(
              color: Colors.white,
              fontSize: w * 0.03,
              fontFamily: "PoppinsBold",
            ),
          ),
        ),
        SizedBox(height: h * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/icons/google.png", width: 40),
            const SizedBox(width: 30),
            Image.asset("assets/images/icons/facebook.png", width: 40),
            const SizedBox(width: 30),
            Image.asset("assets/images/icons/apple.png", width: 40),
          ],
        ),
        SizedBox(height: h * 0.03),
        Center(
          child: Text(
            "Continue as Guest",
            style: TextStyle(
              color: Colors.white,
              fontSize: w * 0.03,
              decoration: TextDecoration.underline,
              fontFamily: "PoppinsSemiBold",
            ),
          ),
        ),
      ],
    );
  }
}
