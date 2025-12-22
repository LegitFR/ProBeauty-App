import 'package:flutter/material.dart';
import 'package:probeauty_app/pages/book_appointment_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SelectProfessionalScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final double rating;
  final List<dynamic> staffList;
  final List<Map<String, dynamic>> selectedServices;

  const SelectProfessionalScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.rating,
    required this.staffList,
    required this.selectedServices,
  });

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            "Select professional",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),

        // ---------------- STAFF GRID ONLY ----------------
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: staffList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final staff = staffList[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(
                        salonId: salonId,
                        salonName: salonName,
                        rating: rating,
                        staff: staff,
                        selectedServices: selectedServices,
                      ),
                    ),
                  );
                },
                child: _professionalCard(staff),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- STAFF CARD UI ----------------
  Widget _professionalCard(Map<String, dynamic> staff) {
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
