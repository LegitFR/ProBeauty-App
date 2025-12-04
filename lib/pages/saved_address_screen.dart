import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {
  String selectedType = "Home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECE3), // soft ivory
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF5ECE3),
        elevation: 0,
        title: const Text(
          "Saved addresses",
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/images/icons/home_icon.svg",
                  height: 14,
                  width: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.rusticSunset,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Home",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                    color: AppColors.rusticSunset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFA7D4F), Color(0xFFC64414)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/images/icons/location_icon.svg",
                    height: 15,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "38/3B, 2 Floor,\nSwathi swadhaa flats, Guruvappa street,\nAyyanavaram, chennai - 600023",
                      style: TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/images/icons/edit_icon.svg",
                    height: 15,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                SvgPicture.asset(
                  "assets/images/icons/add_new_address_icon.svg",
                  height: 14,
                  width: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.rusticSunset,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Add new address",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                    color: AppColors.rusticSunset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFA7D4F), Color(0xFFC64414)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Use Current Location",
                      style: TextStyle(
                        fontFamily: "PoppinsRegular",
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/images/icons/radio_unfilled.svg",
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Or",
                style: TextStyle(
                  fontFamily: "PoppinsMedium",
                  fontSize: 14,
                  color: AppColors.rusticSunset,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _labelField("House No & Floor *"),
            const SizedBox(height: 15),
            _labelField("Building Name & Block no*"),
            const SizedBox(height: 15),
            _labelField("Area & Landmark *"),
            const SizedBox(height: 15),
            _labelField("City *"),
            const SizedBox(height: 15),
            _labelField("District *"),
            const SizedBox(height: 15),
            _labelField("Pincode*"),
            const SizedBox(height: 20),
            const Text(
              "Save this address as",
              style: TextStyle(
                fontFamily: "PoppinsRegular",
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _typeChip("Home"),
                _typeChip("Work"),
                _typeChip("Others"),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFA7D4F), Color(0xFFC64414)],
                ),
              ),
              child: const Center(
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _labelField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "PoppinsRegular",
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.softIvory,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black54),
          ),
          child: const TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        )
      ],
    );
  }

  Widget _typeChip(String type) {
    final bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rusticSunset : AppColors.softIvory,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.rusticSunset : Colors.black45,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontFamily: "PoppinsRegular",
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
