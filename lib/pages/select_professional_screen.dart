import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'book_appointment_screen.dart';

class SelectProfessionalScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final double rating;
  final List<dynamic> staffList;
  final List<Map<String, dynamic>> selectedServices;

  const SelectProfessionalScreen({
    super.key,
    required this.salonName,
    required this.rating,
    required this.staffList,
    required this.selectedServices,
    required this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    print(selectedServices);

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
        title: const Text(
          "Select professional",
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.close, color: Colors.black),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: staffList.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            // -----------------------------------------------
            // 1️⃣ ANY PROFESSIONAL CARD
            // -----------------------------------------------
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  Map<String, dynamic> anyStaff = staffList.first;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(
                        salonId: salonId,
                        salonName: salonName,
                        rating: rating,
                        staff: anyStaff,
                        selectedServices: selectedServices,
                      ),
                    ),
                  );
                },
                child: _anyProfessionalCard(),
              );
            }

            // -----------------------------------------------
            // 2️⃣ INDIVIDUAL STAFF CARD
            // -----------------------------------------------
            final Map<String, dynamic> staff = staffList[index - 1];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookAppointmentScreen(
                      salonId: salonId,
                      salonName: salonName,
                      rating: rating,
                      staff: staff, // ONE STAFF OBJECT
                      selectedServices: selectedServices, // FULL SERVICE LIST
                    ),
                  ),
                );
              },
              child: _professionalCard(staff),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // ANY PROFESSIONAL UI
  // -----------------------------------------------------
  Widget _anyProfessionalCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 40, color: Colors.black),
          SizedBox(height: 12),
          Text(
            "Any professional",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Maximum availability",
            style: TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // INDIVIDUAL STAFF CARD UI
  // -----------------------------------------------------
  Widget _professionalCard(Map<String, dynamic> staff) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12,
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const Text(
            "Staff Name",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            staff["name"] ?? "N/A",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
