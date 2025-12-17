import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  bool _shrink = false;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _shrink = true);
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOutCubic,
            left: 0,
            right: 0,
            top: _shrink ? size.height * 0.34 : 0,
            bottom: _shrink ? size.height * 0.08 : 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              decoration: BoxDecoration(
                color: AppColors.rusticSunset,
                borderRadius: BorderRadius.circular(_shrink ? 50 : 0),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _showContent ? 1 : 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hello!",
                        style: TextStyle(
                          fontSize: size.width * 0.075,
                          color: Colors.white,
                          fontFamily: "PlayfairDisplayBold",
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create your account or login in to book and manage your appointments.",
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color: Colors.white,
                          fontFamily: "PoppinsRegular",
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SizedBox(
                      width: size.width * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            fontSize: size.width * 0.04,
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: size.width * 0.65,
                      height: 45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      "Sign in with",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.03,
                        fontFamily: "PoppinsBold",
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/icons/google.png",
                            width: 40),
                        const SizedBox(width: 30),
                        Image.asset("assets/images/icons/facebook.png",
                            width: 40),
                        const SizedBox(width: 30),
                        Image.asset("assets/images/icons/apple.png", width: 40),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      "Continue as Guest",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.03,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        fontFamily: "PoppinsSemiBold",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/logos/probeauty_app_logo.png",
                width: size.width * 0.5,
                height: size.height * 0.25,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
