// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter the complete 6-digit OTP.",
          ),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final Map<String, dynamic> bodyData = {"otp": otp};

    if (contact.contains("@")) {
      bodyData["email"] = contact;
    } else {
      bodyData["phone"] = contact;
    }

    try {
      final response = await ApiClient.post(
        "/api/v1/auth/confirm-registration",
        body: bodyData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens and user info from confirm-registration response
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", data["accessToken"] ?? "");
        await prefs.setString("refreshToken", data["refreshToken"] ?? "");

        final user = data["user"];
        if (user != null) {
          await prefs.setString("userId", user["id"] ?? "");
          await prefs.setString("userName", user["name"] ?? "");
          await prefs.setString("userEmail", user["email"] ?? "");
          if (user["phone"] != null) {
            await prefs.setString("userPhone", user["phone"]);
          }
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account verified successfully."),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          "/onboarding",
          (route) => false,
        );
      } else {
        final err = jsonDecode(response.body);
        final msg = err["message"] ?? "Invalid or expired OTP. Please try again.";
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to verify OTP right now. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: (screenWidth - screenWidth * 0.16 - screenWidth * 0.05) / 6,
                    height: 52,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
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
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }

                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }

                        if (index == 5 && value.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          _verifyOtp(contact);
                        }
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: screenHeight * 0.06),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
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
            ],
          ),
        ),
      ),
    );
  }
}
