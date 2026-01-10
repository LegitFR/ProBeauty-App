import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/book_appointment_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SelectProfessionalScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final List<dynamic> staffList;
  final List<Map<String, dynamic>> selectedServices;

  const SelectProfessionalScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.staffList,
    required this.selectedServices,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: true,
      child: Scaffold(
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

        // ---------------- STAFF GRID ----------------
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: staffList.length + 1, // 🔥 +1 for Any staff
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              // 🟢 FIRST CARD → ANY STAFF
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(
                          salonId: salonId,
                          salonName: salonName,
                          staff: null, // 🔥 indicates any staff
                          selectedServices: selectedServices,
                        ),
                      ),
                    );
                  },
                  child: _anyStaffCard(context),
                );
              }

              // 🔵 NORMAL STAFF CARDS
              final staff = staffList[index - 1];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(
                        salonId: salonId,
                        salonName: salonName,
                        staff: staff,
                        selectedServices: selectedServices,
                      ),
                    ),
                  );
                },
                child: _professionalCard(staff, context),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- ANY STAFF CARD ----------------
  Widget _anyStaffCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.rusticSunset.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rusticSunset,
          width: 2.5,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_2_outlined,
            size: 34,
            color: AppColors.rusticSunset,
          ),
          const SizedBox(height: 12),
          Text(
            "Any Staff",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
              color: AppColors.rusticSunset,
            ),
          ),
          // const SizedBox(height: 4),
          // Text(
          //   "Any Staff",
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     fontFamily: "PoppinsRegular",
          //     fontSize: 12,
          //     color: Colors.black54,
          //   ),
          // ),
        ],
      ),
    );
  }

  // ---------------- NORMAL STAFF CARD ----------------
  Widget _professionalCard(Map<String, dynamic> staff, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 30),
          const SizedBox(height: 12),
          Text(
            staff["name"] ??
                AppLocalizations.of(context)!.selectProfessionalFallbackName,
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
