import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logos/probeauty_app_logo.png",
              width: screenWidth * 0.5,
              height: screenHeight * 0.25,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.05),
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.03,
                horizontal: screenWidth * 0.06,
              ),
              decoration: BoxDecoration(
                color: AppColors.rusticSunset,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hello!",
                      style: TextStyle(
                        fontSize: screenWidth * 0.075,
                        color: Colors.white,
                        fontFamily: "PlayfairDisplayBold",
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Create your account or login in to book and manage your appointments.",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        fontFamily: "PoppinsRegular",
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // 🔹 LOGIN BUTTON
                  SizedBox(
                    width: screenWidth * 0.65,
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
                          fontSize: screenWidth * 0.04,
                          color: AppColors.rusticSunset,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 SIGNUP BUTTON
                  SizedBox(
                    width: screenWidth * 0.65,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.rusticSunset,
                        side: const BorderSide(color: Colors.white, width: 1.5),
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
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  Text(
                    "Sign in with",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontFamily: "PoppinsBold"),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/google.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/facebook.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/apple.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          fontFamily: "PoppinsSemiBold"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
