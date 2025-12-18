import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

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

  // 🟢 Login function
  Future<void> _login() async {
    if (_isLoading) return;

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email/phone and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url =
          Uri.parse("https://probeauty-backend.onrender.com/api/v1/auth/login");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
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

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );

        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: AppBar(
          backgroundColor: AppColors.rusticSunset,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.225,
              decoration: const BoxDecoration(
                color: AppColors.rusticSunset,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.05,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08,
                          fontFamily: "PlayfairDisplayBold",
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Log in!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontFamily: "PoppinsRegular",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      style: const TextStyle(color: AppColors.rusticSunset),
                      cursorColor: AppColors.rusticSunset,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.call,
                          color: _emailFocus.hasFocus ||
                                  _emailController.text.isNotEmpty
                              ? AppColors.rusticSunset
                              : AppColors.greyTone,
                        ),
                        hintText: "Email or Phone number",
                        hintStyle: const TextStyle(
                          color: AppColors.greyTone,
                          fontFamily: "PoppinsRegular",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.greyTone, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.rusticSunset, width: 1.2),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextField(
                      style: const TextStyle(color: AppColors.rusticSunset),
                      cursorColor: AppColors.rusticSunset,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: _passwordFocus.hasFocus ||
                                  _passwordController.text.isNotEmpty
                              ? AppColors.rusticSunset
                              : AppColors.greyTone,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _passwordFocus.hasFocus ||
                                    _passwordController.text.isNotEmpty
                                ? AppColors.rusticSunset
                                : AppColors.greyTone,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: AppColors.greyTone,
                          fontFamily: "PoppinsRegular",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.greyTone, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.rusticSunset, width: 1.2),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),
                    SizedBox(
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
                        onPressed: _login,
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
                                "Log in",
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
          ],
        ),
      ),
    );
  }
}
