// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
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
        // ApiClient already handles storing tokens via refresh logic,
        // but we still store user profile data
        final prefs = await SharedPreferences.getInstance();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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

    return SafeArea(
      child: Scaffold(
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
                    SizedBox(height: height * 0.05),
                    SizedBox(
                      width: width * 0.65,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _login,
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
                  ],
                ),
              ),
            ],
          ),
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
