import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _simulateLogin() {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, "/onboarding", (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.06),

              // 🔹 Title (Left Aligned)
              Text(
                "Enter OTP",
                style: TextStyle(
                  color: AppColors.rusticSunset,
                  fontFamily: "PoppinsSemiBold",
                  fontSize: screenWidth * 0.06,
                ),
                textAlign: TextAlign.left,
              ),

              SizedBox(height: screenHeight * 0.01),

              // 🔸 Subtitle (Left Aligned)
              Text(
                "A 4 digit code has been sent to\n+91 9940510872",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "PoppinsRegular",
                  fontSize: screenWidth * 0.034,
                ),
                textAlign: TextAlign.left,
              ),

              SizedBox(height: screenHeight * 0.04),

              // 🔢 OTP Boxes (Centered Row)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: screenWidth * 0.15,
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontFamily: "PoppinsBold",
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.greyTone,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.rusticSunset,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: screenHeight * 0.06),

              // 🔘 Verify Button (Centered)
              Center(
                child: SizedBox(
                  width: screenWidth * 0.65,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rusticSunset,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _simulateLogin,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(AppColors.greyTone),
                              SizedBox(width: screenWidth * 0.015),
                              _buildDot(Colors.white),
                              SizedBox(width: screenWidth * 0.015),
                              _buildDot(AppColors.greyTone),
                            ],
                          )
                        : Text(
                            "Verify OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontFamily: "PoppinsRegular",
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
