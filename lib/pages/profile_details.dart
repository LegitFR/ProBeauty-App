import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({Key? key}) : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final TextEditingController _firstNameController =
      TextEditingController(text: 'John');
  final TextEditingController _lastNameController =
      TextEditingController(text: 'Son');
  final TextEditingController _phoneController =
      TextEditingController(text: '9940510872');
  final TextEditingController _emailController =
      TextEditingController(text: 'johnsonkannan@gmail.com');
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String _selectedCountryCode = '+91';
  String? _selectedEmailOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit profile details',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontFamily: "PoppinsSemiBold"),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('First Name'),
            const SizedBox(height: 8),
            _buildTextField(_firstNameController),
            const SizedBox(height: 20),
            _buildLabel('Last Name'),
            const SizedBox(height: 8),
            _buildTextField(_lastNameController),
            const SizedBox(height: 20),
            _buildLabel('Mobile number'),
            const SizedBox(height: 8),
            _buildPhoneField(),
            const SizedBox(height: 20),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(_emailController),
            const SizedBox(height: 20),
            _buildLabel('Date of birth'),
            const SizedBox(height: 8),
            _buildDateFields(),
            const SizedBox(height: 20),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildDropdownField(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
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
        style: const TextStyle(
            fontFamily: "PoppinsRegular", fontSize: 14, color: Colors.black),
        controller: controller,
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              fontFamily: "PoppinsRegular", fontSize: 14, color: Colors.black),
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
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(_phoneController),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDateTextField(_dayController, 'Day'),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildDateDropdown('Month'),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildDateTextField(_yearController, 'Year'),
        ),
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
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: Colors.grey, fontFamily: "PoppinsRegular"),
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
              style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: "PoppinsRegular",
                  fontSize: 14.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          isExpanded: true,
          items: const [],
          onChanged: null,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEmailOption,
          hint: const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'Select Option',
              style:
                  TextStyle(color: Colors.grey, fontFamily: "PoppinsRegular"),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          isExpanded: true,
          items: ['Option 1', 'Option 2', 'Option 3']
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedEmailOption = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle save action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rusticSunset,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: "PoppinsRegular"),
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
