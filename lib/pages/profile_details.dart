// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/services/api_client.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final String _countryCode = '+351';
  // String? _selectedEmailOption;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    loadUserData(); // 🔥 Load values from SharedPreferences
  }

  // ⭐ Load actual saved details
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final fullName = prefs.getString("userName") ?? "";
    final phone = prefs.getString("userPhone") ?? "";
    final email = prefs.getString("userEmail") ?? "";

    // Split full name → first + last
    final nameParts = fullName.split(" ");
    String first = nameParts.isNotEmpty ? nameParts.first : "";
    String last = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    setState(() {
      _firstNameController.text = first;
      _lastNameController.text = last;
      _phoneController.text = phone;
      _emailController.text = email;
    });
  }

  // 🔴 SHOW MESSAGE
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  // 🔵 API CALL → UPDATE PROFILE
  Future<void> _updateProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_saving) return;

    final first = _firstNameController.text.trim();
    final email = _emailController.text.trim();
    final last = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final fullName = "$first $last".trim();

    if (first.isEmpty) {
      _showMessage("Please enter your first name.");
      return;
    }

    if (last.isEmpty) {
      _showMessage("Please enter your last name.");
      return;
    }

    if (email.isEmpty) {
      _showMessage("Please enter your email address.");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showMessage("Please enter a valid email address.");
      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^\d{9}$').hasMatch(phone)) {
      _showMessage("Phone number must be exactly 9 digits.");
      return;
    }

    setState(() => _saving = true);

    final body = {
      "name": fullName,
      if (phone.isNotEmpty) "phone": phone,
    };

    try {
      final response = await ApiClient.patch(
        "/api/v1/user/me",
        body: body,
      );

      print(body);

      final data = jsonDecode(response.body);
      print("STATUS");
      print(data);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userName", fullName);
        await prefs.setString("userPhone", phone);

        _showMessage(l10n.profileUpdateSuccess);
        Navigator.pop(context, true);
      } else {
        _showMessage(
          l10n.profileUpdateFailed,
        );
      }
    } catch (e) {
      _showMessage(
        "Unable to update profile right now. Please try again.",
      );
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          l10n.profileEditTitle,
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontFamily: "PoppinsSemiBold"),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(l10n.profileFirstNameLabel, required: true),
            const SizedBox(height: 8),
            _buildTextField(_firstNameController),
            const SizedBox(height: 20),
            _buildLabel(l10n.profileLastNameLabel, required: true),
            const SizedBox(height: 8),
            _buildTextField(_lastNameController),
            const SizedBox(height: 20),
            _buildLabel(l10n.profileMobileLabel),
            const SizedBox(height: 8),
            _buildPhoneField(),
            const SizedBox(height: 20),
            _buildLabel(l10n.profileEmailLabel),
            const SizedBox(height: 8),
            _buildTextField(_emailController, readOnly: true),
            const SizedBox(height: 20),
            // _buildLabel(l10n.profileDobLabel),
            const SizedBox(height: 8),
            // _buildDateFields(),
            // const SizedBox(height: 20),
            // // _buildLabel(l10n.profileEmailLabel),
            // // const SizedBox(height: 8),
            // // _buildDropdownField(),
            // // const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontFamily: "PoppinsSemiBold",
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextField(
        readOnly: readOnly,
        cursorColor: AppColors.rusticSunset,
        controller: controller,
        style: const TextStyle(
            fontFamily: "PoppinsRegular", fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          filled: readOnly,
          fillColor:
              readOnly ? Colors.grey.withOpacity(0.08) : Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black87,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              "+351",
              style: const TextStyle(
                fontFamily: "PoppinsMedium",
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 24,
            color: Colors.black26,
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.rusticSunset,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintText: "912345678",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rusticSunset,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _saving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                l10n.profileSaveButton,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: "PoppinsRegular"),
              ),
      ),
    );
  }
}
