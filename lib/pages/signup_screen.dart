import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/resources/AppColors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus Nodes
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

  Color _iconColor(TextEditingController controller, FocusNode focusNode) {
    if (focusNode.hasFocus || controller.text.isNotEmpty) {
      return AppColors.rusticSunset;
    } else {
      return AppColors.greyTone;
    }
  }

  // 🔹 Backend Integration Function
  Future<void> _signupUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        contact.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final url =
        Uri.parse("https://probeauty-backend.onrender.com/api/v1/auth/signup");

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

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!")),
        );
        Navigator.pushNamed(
          context,
          "/OTP",
          arguments: contact,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
            onPressed: () {
              Navigator.pop(context);
            },
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
                        "Welcome,",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08,
                          fontFamily: "PlayfairDisplayBold",
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Sign up!",
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

            // 🔸 Signup Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // 🧍‍♂️ First Name Field
                    TextField(
                      style: const TextStyle(color: AppColors.rusticSunset),
                      cursorColor: AppColors.rusticSunset,
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color:
                              _iconColor(_firstNameController, _firstNameFocus),
                        ),
                        hintText: "First Name",
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
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // 🧍‍♀️ Last Name Field
                    TextField(
                      style: const TextStyle(color: AppColors.rusticSunset),
                      cursorColor: AppColors.rusticSunset,
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color:
                              _iconColor(_lastNameController, _lastNameFocus),
                        ),
                        hintText: "Last Name",
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
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // 📱 Email or Phone Field
                    TextField(
                      style: const TextStyle(color: AppColors.rusticSunset),
                      cursorColor: AppColors.rusticSunset,
                      controller: _contactController,
                      focusNode: _contactFocus,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.call,
                          color: _iconColor(_contactController, _contactFocus),
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
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.02),

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
                          color:
                              _iconColor(_passwordController, _passwordFocus),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color:
                                _iconColor(_passwordController, _passwordFocus),
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
                      onChanged: (_) => setState(() {}),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // 🔘 Get OTP Button (Backend connected)
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
                        onPressed: _signupUser, // 🔥 Backend integrated
                        child: Text(
                          "Get OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontFamily: "PoppinsRegular",
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already a member? ",
                          style: TextStyle(
                            color: AppColors.greyTone,
                            fontSize: screenWidth * 0.03,
                            fontFamily: "PoppinsBold",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.popAndPushNamed(context, "/login");
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.rusticSunset,
                              fontSize: screenWidth * 0.03,
                              fontFamily: "PoppinsBold",
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // ⚫ Horizontal Divider with "Or"
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
                      "Sign up with",
                      style: TextStyle(
                        color: AppColors.rusticSunset,
                        fontSize: screenWidth * 0.03,
                        fontFamily: "PoppinsBold",
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

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

                    SizedBox(height: screenHeight * 0.05),
                    // ... rest of your UI (Login text, social icons, etc.)
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
