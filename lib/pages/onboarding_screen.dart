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

  final List<Map<String, String>> texts = [
    {
      "title": "WELCOME, BE UNIQUE",
      "subtitle":
          "Pre-book your appointment with us and\n enjoy enhancing your beauty"
    },
    {
      "title": "BOOK LOCAL BEAUTY AND SERVICES",
      "subtitle": "We help you find your favorite kind of\nservices"
    },
    {
      "title": "We Style and you smile bright",
      "subtitle":
          "join us to discover your ideal partner and\nkindler romance along the way."
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, "/main");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background shape
          Positioned(
            top: screenHeight * 0.001,
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

          // Phone frame
          Positioned(
            top: screenHeight * 0.11,
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
                        itemBuilder: (_, index) {
                          return Image.asset(images[index], fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: screenHeight * 0.17 - 50,
            // 0.17 = dot position
            // subtract space so text appears BELOW dots
            left: 24, // stick to left of screen
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts[_currentPage]["title"]!,
                  style: const TextStyle(
                    fontFamily: "PlayfairDisplayBold",
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texts[_currentPage]["subtitle"]!,
                  style: const TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Skip
          if (_currentPage < 2)
            Positioned(
              top: screenHeight * 0.07,
              left: screenWidth * 0.08,
              child: GestureDetector(
                onTap: () => _pageController.jumpToPage(2),
                child: Text(
                  "Skip",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          // Indicators
          Positioned(
            bottom: screenHeight * 0.22,
            child: Row(
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

          // Buttons
          Positioned(
            bottom: screenHeight * 0.035,
            right: _currentPage < 2 ? screenWidth * 0.08 : null,
            child: _currentPage < 2
                ? GestureDetector(
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
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 28),
                    ),
                  )
                : SizedBox(
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
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Get Started",
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
