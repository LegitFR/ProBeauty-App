import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

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

  void _onFocusChange() {
    setState(() {}); // rebuild UI when focus or text changes
  }

  void _simulateLogin() {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    });
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

    return Scaffold(
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
          // 🔹 Top Curved Header
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

          // 🔸 Login Fields Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 📱 Email or Phone Field
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

                  // 🔒 Password Field
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

                  SizedBox(height: screenHeight * 0.015),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.rusticSunset,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: screenWidth * 0.028,
                              fontFamily: "PoppinsBold",
                              color: AppColors.greyTone,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.greyTone,
                            fontFamily: "PoppinsBold",
                            fontSize: screenWidth * 0.028,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.035),

                  // 🔘 Login Button
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
                              "Log in",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontFamily: "PoppinsRegular",
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // ⚫ Divider with "OR"
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.greyTone,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontFamily: "PoppinsBold",
                            fontSize: screenWidth * 0.03,
                            color: AppColors.greyTone,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.greyTone,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  Text(
                    "Sign in with",
                    style: TextStyle(
                      color: AppColors.rusticSunset,
                      fontSize: screenWidth * 0.03,
                      fontFamily: "PoppinsBold",
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // 🧠 Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/google.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/facebook.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/icons/apple.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // 🩶 Signup Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.greyTone,
                          fontSize: screenWidth * 0.03,
                          fontFamily: "PoppinsBold",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.popAndPushNamed(context, "/signup");
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.rusticSunset,
                            fontSize: screenWidth * 0.03,
                            fontFamily: "PoppinsBold",
                          ),
                        ),
                      ),
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
}
