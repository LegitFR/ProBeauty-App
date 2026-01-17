// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import "../resources/AppColors.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<String> images = [
    "assets/images/onboarding/image1.png",
    "assets/images/onboarding/image2.png",
    "assets/images/onboarding/image3.png",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate loading delay
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, "/main");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 🟡 Static background decorative image
            Positioned(
              top: screenHeight * 0.0008,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Image.asset(
                  "assets/images/onboarding/background_shape.png",
                  height: screenHeight * 0.35,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 🖼️ Onboarding frame
            Positioned(
              top: screenHeight * 0.15,
              left: screenWidth * 0.14,
              right: screenWidth * 0.12,
              child: Container(
                height: screenHeight * 0.6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(70),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              images[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Skip button
            if (_currentPage < 2)
              Positioned(
                top: screenHeight * 0.07,
                left: screenWidth * 0.08,
                child: GestureDetector(
                  onTap: () => _pageController.jumpToPage(2),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "PoppinsRegular",
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),

            // 🔸 Page indicators
            Positioned(
              bottom: screenHeight * 0.227,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 30,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.rusticSunset
                          : Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),

            // ⚪ Buttons
            Positioned(
              bottom: screenHeight * 0.05,
              right: _currentPage < 2 ? screenWidth * 0.08 : null,
              child: _currentPage < 2
                  ? // 👉 Circular arrow button
                  GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: AppColors.rusticSunset,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )
                  : // 👉 “Get Started” button with loading dots
                  SizedBox(
                      width: screenWidth * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _simulateLoading,
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: index == 1
                                          ? Colors.white
                                          : Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              )
                            : Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "PoppinsRegular",
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
