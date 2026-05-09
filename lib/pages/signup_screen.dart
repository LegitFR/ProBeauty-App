// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';
import 'package:probeauty_app/services/google_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameFocus.addListener(() => setState(() {}));
    _lastNameFocus.addListener(() => setState(() {}));
    _contactFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _contactFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signupUser() async {
    if (_isLoading) return;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        contact.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.signupEmptyFieldsError,
          ),
        ),
      );
      return;
    }

    if (contact.contains("@")) {
      final emailRegex = RegExp(
        r'^[^@]+@[^@]+\.[^@]+',
      );

      if (!emailRegex.hasMatch(contact)) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please enter a valid email address.",
            ),
          ),
        );

        return;
      }
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 6 characters.",
          ),
        ),
      );

      return;
    }
    final Map<String, dynamic> bodyData = {
      "name": "$firstName $lastName",
      "password": password,
      "role": "customer",
    };

    if (contact.contains("@")) {
      bodyData["email"] = contact;
    } else {
      bodyData["phone"] = contact;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post(
        "/api/v1/auth/signup",
        body: bodyData,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || data['success'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.signupSuccessMessage,
            ),
          ),
        );
        Navigator.pushNamed(context, "/OTP", arguments: contact);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.signupFailedMessage,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to create account right now.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🟠 COLLAPSING HEADER
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent, // IMPORTANT
            expandedHeight: height * 0.25,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final bool isCollapsed =
                    constraints.biggest.height <= kToolbarHeight + 10;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 🟠 EXPANDED HEADER WITH CURVED BOTTOM
                    if (!isCollapsed)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                        child: Container(
                          color: AppColors.rusticSunset,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.08,
                            vertical: height * 0.05,
                          ),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.signupWelcome,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.08,
                                  fontFamily: "PlayfairDisplayBold",
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.signupSubtitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.05,
                                  fontFamily: "PoppinsRegular",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (isCollapsed)
                      Container(
                        color: AppColors.rusticSunset,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 14),
                        child: const Text(
                          "Sign up!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: "PoppinsMedium",
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // 🔹 FORM CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.06,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.person_outline,
                      hint: l10n.signupFirstNameHint,
                      isActive: _firstNameFocus.hasFocus ||
                          _firstNameController.text.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.person_outline,
                      hint: l10n.signupLastNameHint,
                      isActive: _lastNameFocus.hasFocus ||
                          _lastNameController.text.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _contactController,
                    focusNode: _contactFocus,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.call,
                      hint: l10n.signupContactHint,
                      isActive: _contactFocus.hasFocus ||
                          _contactController.text.isNotEmpty,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    cursorColor: AppColors.rusticSunset,
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline,
                      hint: l10n.signupPasswordHint,
                      isActive: _passwordFocus.hasFocus ||
                          _passwordController.text.isNotEmpty,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  SizedBox(
                    width: width * 0.65,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rusticSunset,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        l10n.signupGetOtpButton,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.04,
                          fontFamily: "PoppinsRegular",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already a member? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "PoppinsSemiBold",
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          "login",
                          style: TextStyle(
                            color: AppColors.rusticSunset,
                            fontFamily: "PoppinsBold",
                          ),
                        ),
                      ),
                    ],
                  ),
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

                  const SizedBox(height: 30),
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
                          if (_isGoogleLoading) return;

                          setState(() => _isGoogleLoading = true);

                          final success =
                              await GoogleAuthService.signInWithGoogle();

                          if (!mounted) return;

                          if (!success) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Unable to sign in with Google.",
                                ),
                              ),
                            );

                            setState(() => _isGoogleLoading = false);

                            return;
                          }

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
                      // SvgPicture.asset(
                      //   "assets/images/icons/facebook.svg",
                      //   width: 25,
                      //   height: 25,
                      // ),
                      // const SizedBox(width: 40),
                      // SvgPicture.asset(
                      //   "assets/images/icons/apple.svg",
                      //   width: 25,
                      //   height: 25,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      prefixIcon: Icon(
        icon,
        color: isActive ? AppColors.rusticSunset : AppColors.greyTone,
      ),
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
