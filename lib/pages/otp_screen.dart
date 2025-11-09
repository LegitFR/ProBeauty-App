import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/resources/AppColors.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
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

  Future<void> _verifyOtp(String contact) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final url =
        Uri.parse("http://192.168.0.3:5000/api/v1/auth/confirm-registration");

    final Map<String, dynamic> bodyData = {"otp": otp};
    if (contact.contains("@")) {
      bodyData["email"] = contact;
    } else {
      bodyData["phone"] = contact;
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account verified successfully!")),
        );
        // Navigate to onboarding after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, "/onboarding", (route) => false);
        });
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Verification failed")),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = ModalRoute.of(context)?.settings.arguments as String?;
    if (contact == null) {
      return const Scaffold(
        body: Center(child: Text("No contact information provided")),
      );
    }

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

              // Title
              Text(
                "Enter OTP",
                style: TextStyle(
                  color: AppColors.rusticSunset,
                  fontFamily: "PoppinsSemiBold",
                  fontSize: screenWidth * 0.06,
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // Subtitle
              Text(
                contact.contains("@")
                    ? "A 6-digit code has been sent to\n$contact"
                    : "A 6-digit code has been sent to\n+91 $contact",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "PoppinsRegular",
                  fontSize: screenWidth * 0.034,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // OTP Inputs
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: screenWidth * 0.10,
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
                          if (value.isNotEmpty && index < 7) {
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

              // Verify Button
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
                    onPressed: () => _verifyOtp(contact),
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
