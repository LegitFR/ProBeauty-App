import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _otpSent = false;
  bool _isVerifyingOtp = false;
  bool _otpVerified = false;

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isResettingPassword = false;

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    for (final controller in _otpControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email address."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        "/api/v1/auth/forgot-password",
        body: {
          "email": email,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _otpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP sent successfully."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Unable to send OTP.",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifyingOtp) return;

    final otp = _otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the complete OTP."),
        ),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    try {
      final response = await ApiClient.post(
        "/api/v1/auth/verify-forgot-password-otp",
        body: {
          "email": _emailController.text.trim(),
          "otp": otp,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _otpVerified = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Invalid OTP",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifyingOtp = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_isResettingPassword) return;

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 6 characters.",
          ),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match.",
          ),
        ),
      );
      return;
    }

    final otp = _otpControllers.map((e) => e.text).join();

    setState(() => _isResettingPassword = true);

    try {
      final response = await ApiClient.post(
        "/api/v1/auth/reset-password",
        body: {
          "email": _emailController.text.trim(),
          "otp": otp,
          "newPassword": newPassword,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Password reset successfully.",
            ),
          ),
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Unable to reset password.",
            ),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      await ApiClient.post(
        "/api/v1/auth/resend-forgot-password-otp",
        body: {
          "email": _emailController.text.trim(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP sent again."),
        ),
      );
    } catch (_) {}
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    required bool isActive,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: isActive ? AppColors.rusticSunset : AppColors.greyTone,
      ),
      hintText: hint,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.greyTone,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.rusticSunset,
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.rusticSunset,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: height * 0.25,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.05,
              ),
              decoration: const BoxDecoration(
                color: AppColors.rusticSunset,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.08,
                      fontFamily: "PlayfairDisplayBold",
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _otpVerified
                        ? "Create a new password"
                        : _otpSent
                            ? "Enter the OTP sent to your email"
                            : "Enter your email to receive a reset OTP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.04,
                      fontFamily: "PoppinsRegular",
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.06,
              ),
              child: Column(
                children: [
                  if (!_otpSent) ...[
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      cursorColor: AppColors.rusticSunset,
                      decoration: _inputDecoration(
                        icon: Icons.email_outlined,
                        hint: "Email Address",
                        isActive: _emailFocus.hasFocus ||
                            _emailController.text.isNotEmpty,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    SizedBox(
                      width: width * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Send OTP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "PoppinsRegular",
                                ),
                              ),
                      ),
                    ),
                  ] else if (!_otpVerified) ...[
                    Text(
                      _emailController.text.trim(),
                      style: const TextStyle(
                        color: AppColors.rusticSunset,
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;

                          for (final controller in _otpControllers) {
                            controller.clear();
                          }
                        });
                      },
                      child: const Text(
                        "Change Email",
                        style: const TextStyle(
                          color: AppColors.rusticSunset,
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          child: TextField(
                            controller: _otpControllers[index],
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              counterText: "",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.rusticSunset,
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
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: AppColors.rusticSunset,
                          fontFamily: "PoppinsSemiBold",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: width * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isVerifyingOtp ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isVerifyingOtp
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      cursorColor: AppColors.rusticSunset,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        hintText: "New Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      cursorColor: AppColors.rusticSunset,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        hintText: "Confirm Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: width * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isResettingPassword ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isResettingPassword
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
