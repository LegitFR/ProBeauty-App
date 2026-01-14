import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => _SavedAddressScreenState();
}

class _SavedAddressScreenState extends State<SavedAddressScreen> {
  String selectedType = "Home";
  bool _showForm = false;

  // Controllers
  final TextEditingController houseController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  bool isLoading = false;

  // For Edit Mode
  Map<String, dynamic>? defaultAddress;
  bool isEditMode = false; // True when editing
  String? editAddressId; // Holds id of address being edited
  bool _addressLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDefaultAddress();
  }

  // -------------------------------------------------------
  // GET DEFAULT ADDRESS
  // -------------------------------------------------------
  Future<void> _fetchDefaultAddress() async {
    setState(() => _addressLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    if (token == null) {
      setState(() => _addressLoading = false);
      return;
    }

    final url =
        Uri.parse("https://probeauty-backend.onrender.com/api/v1/addresses");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List list = json["data"];

      if (list.isNotEmpty) {
        final d = list.firstWhere(
          (a) => a["isDefault"] == true,
          orElse: () => null,
        );

        if (d != null) {
          defaultAddress = d;
        }
      }
    }

    setState(() => _addressLoading = false);
  }

  Widget _addressSkeleton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade400),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade400),
                const SizedBox(height: 6),
                Container(height: 12, width: 160, color: Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // POPULATE FIELDS WHEN EDIT IS PRESSED
  // -------------------------------------------------------
  void _enterEditMode() {
    if (defaultAddress == null) return;

    setState(() {
      houseController.text = defaultAddress!["addressLine1"] ?? "";
      buildingController.text = defaultAddress!["addressLine2"] ?? "";
      landmarkController.text = "";
      cityController.text = defaultAddress!["city"] ?? "";
      districtController.text = defaultAddress!["city"] ?? "";
      pincodeController.text = defaultAddress!["postalCode"] ?? "";

      selectedType = "Home";
      editAddressId = defaultAddress!["id"];
      isEditMode = true;
      _showForm = true; // 🔥 KEY
    });
  }

  // -------------------------------------------------------
  // CREATE OR UPDATE ADDRESS
  // -------------------------------------------------------
  Future<void> _saveOrUpdateAddress() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("accessToken");

      if (token == null) {
        print("⚠ No token found");
        return;
      }

      // Build body
      final body = {
        "fullName": "User Name",
        "phone": "+91-9876543210",
        "addressLine1": houseController.text,
        "addressLine2": buildingController.text,
        "city": cityController.text,
        "state": districtController.text,
        "postalCode": pincodeController.text,
        "country": "India",
        "isDefault": selectedType == "Home" ? true : false
      };

      http.Response response;

      if (isEditMode && editAddressId != null) {
        // UPDATE MODE
        final url = Uri.parse(
            "https://probeauty-backend.onrender.com/api/v1/addresses/$editAddressId");

        response = await http.patch(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        );
      } else {
        // CREATE NEW ADDRESS
        final url = Uri.parse(
            "https://probeauty-backend.onrender.com/api/v1/addresses");

        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? AppLocalizations.of(context)!.savedAddressUpdatedSuccess
                : AppLocalizations.of(context)!.savedAddressSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh top default address
        _fetchDefaultAddress();

        setState(() {
          isEditMode = false;
          editAddressId = null;
        });
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.savedAddressFailed(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5ECE3),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFF5ECE3),
          elevation: 0,
          title: Text(
            l10n.savedAddressTitle,
            style: const TextStyle(
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
              // ---- HOME TITLE ----
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
                  Text(
                    l10n.savedAddressHomeLabel,
                    style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 14,
                      color: AppColors.rusticSunset,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // -------------------------------------------------
              // DEFAULT ADDRESS CARD
              // -------------------------------------------------
              if (_addressLoading)
                _addressSkeleton()
              else if (defaultAddress != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA7D4F), Color(0xFFC64414)],
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
                            Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${defaultAddress!["addressLine1"]},\n"
                          "${defaultAddress!["addressLine2"]},\n"
                          "${defaultAddress!["city"]} - ${defaultAddress!["postalCode"]}",
                          style: const TextStyle(
                            fontFamily: "PoppinsRegular",
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _enterEditMode,
                        child: SvgPicture.asset(
                          "assets/images/icons/edit_icon.svg",
                          height: 15,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // ---------------- ADD NEW ADDRESS ----------------
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEditMode = false;
                    editAddressId = null;
                    _showForm = true;

                    houseController.clear();
                    buildingController.clear();
                    landmarkController.clear();
                    cityController.clear();
                    districtController.clear();
                    pincodeController.clear();

                    selectedType = "Home";
                  });
                },
                child: Row(
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
                    Text(
                      AppLocalizations.of(context)!.savedAddressAddNew,
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 14,
                        color: AppColors.rusticSunset,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FORM FIELDS
              if (_showForm) ...[
                const SizedBox(height: 20),

                _labelField(l10n.savedAddressHouseLabel, houseController),
                const SizedBox(height: 15),
                _labelField(l10n.savedAddressBuildingLabel, buildingController),
                const SizedBox(height: 15),
                _labelField(l10n.savedAddressLandmarkLabel, landmarkController),
                const SizedBox(height: 15),
                _labelField(l10n.savedAddressCityLabel, cityController),
                const SizedBox(height: 15),
                _labelField(l10n.savedAddressLandmarkLabel, districtController),
                const SizedBox(height: 15),
                _labelField(l10n.savedAddressPincodeLabel, pincodeController),

                const SizedBox(height: 20),
                Text(
                  l10n.savedAddressSaveAs,
                  style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 14,
                      color: Colors.black54),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _typeChip(l10n.savedAddressTypeHome),
                    _typeChip(l10n.savedAddressTypeWork),
                    _typeChip(l10n.savedAddressTypeOthers),
                  ],
                ),

                const SizedBox(height: 26),

                // 🔴 CANCEL + SAVE / UPDATE BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showForm = false;
                            isEditMode = false;
                            editAddressId = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : _saveOrUpdateAddress,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFA7D4F), Color(0xFFC64414)],
                            ),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    isEditMode
                                        ? l10n.savedAddressUpdateButton
                                        : l10n.savedAddressSaveButton,
                                    style: const TextStyle(
                                      fontFamily: "PoppinsSemiBold",
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FIELD WIDGET ----------------
  Widget _labelField(String label, TextEditingController controller) {
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
            border: Border.all(color: Colors.black45),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- TYPE CHIP ----------------
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
