import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/book_appointment_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SelectProfessionalScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String image;

  final List<dynamic> staffList;
  final List<Map<String, dynamic>> selectedServices;

  const SelectProfessionalScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.image,
    required this.staffList,
    required this.selectedServices,
  });

  @override
  State<SelectProfessionalScreen> createState() =>
      _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  int selectedServiceIndex = 0;

  /// serviceId -> staff
  final Map<String, dynamic> selectedStaffPerService = {};

  Map<String, dynamic> get currentService =>
      widget.selectedServices[selectedServiceIndex];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          l10n.selectProfessionalTitle,
          style: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ---------------- SERVICE SELECTOR ----------------
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.selectedServices.length,
              itemBuilder: (context, index) {
                final service = widget.selectedServices[index];
                final isSelected = index == selectedServiceIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedServiceIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.rusticSunset
                          : AppColors.softIvory,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        service["title"],
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 13,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- STAFF GRID ----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: widget.staffList.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final serviceId = currentService["id"];

                  // 🟢 ANY STAFF
                  if (index == 0) {
                    final isSelected =
                        selectedStaffPerService[serviceId] == null &&
                            selectedStaffPerService.containsKey(serviceId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStaffPerService[serviceId] = null;
                        });
                      },
                      child: _anyStaffCard(isSelected),
                    );
                  }

                  final staff = widget.staffList[index - 1];
                  final isSelected =
                      selectedStaffPerService[serviceId]?["id"] == staff["id"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStaffPerService[serviceId] = staff;
                      });
                    },
                    child: _professionalCard(staff, isSelected),
                  );
                },
              ),
            ),
          ),

          // ---------------- CONTINUE BUTTON ----------------
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookAppointmentScreen(
                    salonId: widget.salonId,
                    salonName: widget.salonName,
                    image: widget.image,
                    staff: null,
                    selectedServices: widget.selectedServices,
                    staffMapping: selectedStaffPerService, // 🔥 pass map
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rusticSunset,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              l10n.selectServicesContinue,
              style: const TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 14,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ANY STAFF CARD ----------------
  Widget _anyStaffCard(bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.rusticSunset.withOpacity(0.15)
            : AppColors.rusticSunset.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.rusticSunset : Colors.black26,
          width: 2.5,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_2_outlined,
              size: 34, color: AppColors.rusticSunset),
          SizedBox(height: 12),
          Text(
            "Any Staff",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
              color: AppColors.rusticSunset,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STAFF CARD ----------------
  Widget _professionalCard(Map<String, dynamic> staff, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.rusticSunset.withOpacity(0.15)
            : AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.rusticSunset : Colors.black,
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 30),
          const SizedBox(height: 12),
          Text(
            staff["name"] ?? "Staff",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
