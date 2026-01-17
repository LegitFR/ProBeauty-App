// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/config/api_config.dart';

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

  String _selectedCountryCode = '+91';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // 🔵 API CALL → UPDATE PROFILE
  Future<void> _updateProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_saving) return;

    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final fullName = "$first $last".trim();

    if (first.isEmpty) {
      _showMessage(l10n.profileFirstNameRequired);
      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      _showMessage(l10n.profileInvalidPhone);
      return;
    }

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    if (token == null) {
      _showMessage(l10n.profileUserNotLoggedIn);
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/user/me");

    final body = {"name": fullName, if (phone.isNotEmpty) "phone": phone};

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString("userName", fullName);
        await prefs.setString("userPhone", phone);

        _showMessage(l10n.profileUpdateSuccess);
        Navigator.pop(context, true);
      } else {
        _showMessage(data["message"] ?? l10n.profileUpdateFailed);
      }
    } catch (e) {
      _showMessage(l10n.profileUpdateError(e.toString()));
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      child: Scaffold(
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
                color: Colors.black,
                fontSize: 18,
                fontFamily: "PoppinsSemiBold"),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(l10n.profileFirstNameLabel),
              const SizedBox(height: 8),
              _buildTextField(_firstNameController),
              const SizedBox(height: 20),
              _buildLabel(l10n.profileLastNameLabel),
              const SizedBox(height: 8),
              _buildTextField(_lastNameController),
              const SizedBox(height: 20),
              _buildLabel(l10n.profileMobileLabel),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildLabel(l10n.profileEmailLabel),
              const SizedBox(height: 8),
              _buildTextField(_emailController),
              const SizedBox(height: 20),
              _buildLabel(l10n.profileDobLabel),
              const SizedBox(height: 8),
              _buildDateFields(),
              const SizedBox(height: 20),
              // _buildLabel(l10n.profileEmailLabel),
              // const SizedBox(height: 8),
              // _buildDropdownField(),
              // const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: "PoppinsSemiBold",
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextField(
        cursorColor: AppColors.rusticSunset,
        controller: controller,
        style: const TextStyle(
            fontFamily: "PoppinsRegular", fontSize: 14, color: Colors.black),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.softIvory,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black87, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: ['+91', '+1', '+44', '+61']
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(code),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedCountryCode = value!;
              }),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildTextField(_phoneController)),
      ],
    );
  }

  Widget _buildDateFields() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: _buildDateTextField(_dayController, l10n.profileDayHint)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildDateDropdown(l10n.profileMonthHint)),
        const SizedBox(width: 12),
        Expanded(
            flex: 2,
            child: _buildDateTextField(_yearController, l10n.profileYearHint)),
      ],
    );
  }

  Widget _buildDateTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: TextField(
        cursorColor: AppColors.rusticSunset,
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateDropdown(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              hint,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          items: const [],
          onChanged: null,
        ),
      ),
    );
  }

  // Widget _buildDropdownField() {
  //   final l10n = AppLocalizations.of(context)!;
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppColors.softIvory,
  //       borderRadius: BorderRadius.circular(25),
  //       border: Border.all(color: Colors.black87, width: 1.5),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: _selectedEmailOption,
  //         hint: Padding(
  //           padding: EdgeInsets.only(left: 15),
  //           child: Text(
  //             l10n.profileEmailOptionLabel,
  //             style: const TextStyle(color: Colors.grey),
  //           ),
  //         ),
  //         icon: const Icon(Icons.keyboard_arrow_down, size: 20),
  //         isExpanded: true,
  //         items: ['Option 1', 'Option 2', 'Option 3']
  //             .map((opt) => DropdownMenuItem(
  //                   value: opt,
  //                   child: Text(opt),
  //                 ))
  //             .toList(),
  //         onChanged: (value) => setState(() {
  //           _selectedEmailOption = value;
  //         }),
  //       ),
  //     ),
  //   );
  // }

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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
