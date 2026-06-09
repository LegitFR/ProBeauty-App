// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/services/notification_service.dart';
import 'package:probeauty_app/services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _emailController.addListener(_onFocusChange);
    _passwordController.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  Future<void> _login() async {
    if (_isLoading) return;

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginEmptyFieldsError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        "/api/v1/auth/login",
        body: {
          "identifier": identifier,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", data["accessToken"]);
        await prefs.setString("refreshToken", data["refreshToken"]);
        await prefs.setString("userId", data["user"]["id"]);
        await prefs.setString("userName", data["user"]["name"]);
        await prefs.setString("userEmail", data["user"]["email"]);

        if (data["user"]["phone"] != null) {
          await prefs.setString("userPhone", data["user"]["phone"]);
        }

        await NotificationService.registerDevice();

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid email or password.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String message = "Unable to sign in right now. Please try again later.";

      final error = e.toString().toLowerCase();

      if (error.contains("network")) {
        message = "Please check your internet connection and try again.";
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.rusticSunset,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.softIvory,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔶 ORANGE HEADER (NOW SCROLLS WITH PAGE)
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
                    l10n.loginWelcomeBack,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.08,
                      fontFamily: "PlayfairDisplayBold",
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    l10n.loginSubtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.05,
                      fontFamily: "PoppinsRegular",
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 FORM SECTION
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.06,
              ),
              child: Column(
                children: [
                  TextField(
                    style:
                        TextStyle(fontFamily: "PoppinsRegular", fontSize: 15),
                    controller: _emailController,
                    focusNode: _emailFocus,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.call,
                      hint: l10n.loginEmailHint,
                      isActive: _emailFocus.hasFocus ||
                          _emailController.text.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: height * 0.025),
                  TextField(
                    style:
                        TextStyle(fontFamily: "PoppinsRegular", fontSize: 15),
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline,
                      hint: l10n.loginPasswordHint,
                      isActive: _passwordFocus.hasFocus ||
                          _passwordController.text.isNotEmpty,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.rusticSunset,
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: width * 0.65,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rusticSunset,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const LoadingDots()
                          : Text(
                              l10n.loginButton,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.04,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 20),

                  // -------- Already a member + OR Divider --------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      const Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "PoppinsBold",
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    AppLocalizations.of(context)!.signInWith,
                    style: TextStyle(
                      color: AppColors.rusticSunset,
                      fontSize: size.width * 0.03,
                      fontFamily: "PoppinsBold",
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final success =
                              await GoogleAuthService.signInWithGoogle();

                          if (!success) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Unable to sign in with Google.",
                                ),
                              ),
                            );

                            return;
                          }

                          if (!mounted) return;

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            "/main",
                            (route) => false,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/images/icons/google.svg",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have a account ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "PoppinsSemiBold",
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: AppColors.rusticSunset,
                            fontFamily: "PoppinsBold",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    required bool isActive,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon,
          color: isActive ? AppColors.rusticSunset : AppColors.greyTone),
      suffixIcon: suffix,
      hintText: hint,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.greyTone),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.rusticSunset, width: 1.2),
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double delay = index * 0.2;
        final double value = (_controller.value + delay) % 1.0;

        final double opacity = (1 - (value - 0.5).abs() * 2).clamp(0.3, 1.0);

        final double translateY =
            -6 * (1 - (value - 0.5).abs() * 2).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(0),
        const SizedBox(width: 8),
        _dot(1),
        const SizedBox(width: 8),
        _dot(2),
      ],
    );
  }
}
