import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/resources/AppColors.dart';

/// ------------------------------------------------------------
/// REUSABLE SUCCESS SCREEN
/// Works for:
/// - Appointment booked
/// - Product order placed
/// - Payment success
/// - Any confirmation flow
///
/// Features:
/// - Animated beige → orange gradient background
/// - SVG auto color switching (black → white)
/// - Button slides up from bottom
/// - Auto close or manual continue
/// ------------------------------------------------------------
class AnimatedSuccessScreen extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback onContinue;

  /// Single SVG containing tick + scissors
  final String successSvgPath;

  /// Auto close timer
  final Duration autoCloseAfter;

  const AnimatedSuccessScreen({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onContinue,
    required this.successSvgPath,
    this.autoCloseAfter = const Duration(seconds: 4),
  });

  @override
  State<AnimatedSuccessScreen> createState() => _AnimatedSuccessScreenState();
}

class _AnimatedSuccessScreenState extends State<AnimatedSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _buttonController;
  late AnimationController _iconController;

  bool _showGradient = false;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    // Background morph animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Button slide-up animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Icon scale-in animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Step 1: Icon pop-in
    _iconController.forward();

    // Step 2: Button slides up
    await Future.delayed(const Duration(milliseconds: 600));
    _buttonController.forward();

    // Step 3: Background morph
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showGradient = true);
    _bgController.forward();

    // Step 4: Auto close
    _autoCloseTimer = Timer(widget.autoCloseAfter, () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _buttonController.dispose();
    _iconController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  // -----------------------------
  // GRADIENTS
  // -----------------------------
  LinearGradient _beigeGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.softIvory, AppColors.softIvory],
    );
  }

  LinearGradient _orangeGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.rusticSunset,
        Color.fromARGB(255, 125, 67, 0),
      ],
    );
  }

  Color get _iconColor => _showGradient ? Colors.white : Colors.black;

  Color get _textColor => _showGradient ? Colors.white : Colors.black;

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient.lerp(
                _beigeGradient(),
                _orangeGradient(),
                _bgController.value,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --------------------
                    // SVG ICON
                    // --------------------
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _iconController,
                        curve: Curves.easeOutBack,
                      ),
                      child: SvgPicture.asset(
                        widget.successSvgPath,
                        width: 180,
                        colorFilter: ColorFilter.mode(
                          _iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --------------------
                    // TITLE
                    // --------------------
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 26,
                        color: _textColor,
                      ),
                      child: Text(widget.title),
                    ),

                    const SizedBox(height: 70),

                    // --------------------
                    // SLIDE-UP BUTTON
                    // --------------------
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _buttonController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _autoCloseTimer?.cancel();
                          widget.onContinue();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showGradient
                              ? Colors.white
                              : AppColors.rusticSunset,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          widget.buttonText,
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            color: _showGradient
                                ? AppColors.rusticSunset
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
