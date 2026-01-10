import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/detail_screen.dart';
import 'package:probeauty_app/pages/reviews_screen.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/pages/salon_tabs/salon_tab_bar.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class TeamScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final List<dynamic> staffList;
  final String address;
  final String image;
  final List<dynamic> services;
  final Map<String, dynamic> hours;

  const TeamScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.staffList,
    required this.address,
    required this.hours,
    required this.image,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,

        // ---------------- APP BAR ----------------
        appBar: AppBar(
          backgroundColor: AppColors.softIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            salonName,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),

        // ---------------- BODY ----------------
        body: Column(
          children: [
            // ---------------- TOP TAB BAR ----------------
            SalonTabBar(
              selectedIndex: 2, // TEAM
              onTabTap: (index) {
                if (index == 2) return;

                // SERVICES → replace Team with Services
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SalonDetailScreen(
                        id: salonId,
                        name: salonName,
                        address: address,
                        image: image,
                        services: services,
                        salonStaffList: staffList,
                        hours: hours,
                      ),
                    ),
                  );
                  return;
                }

                // REVIEWS → replace Team with Reviews
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewsScreen(
                        salonId: salonId,
                        salonName: salonName,
                        staffList: staffList,
                        address: address,
                        hours: hours,
                        image: image,
                        services: services,
                      ),
                    ),
                  );
                  return;
                }

                // DETAILS → replace Team with Details
                if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        salonId: salonId,
                        salonName: salonName,
                        address: address,
                        staffList: staffList,
                        hours: hours,
                        services: services,
                        image: image,
                      ),
                    ),
                  );
                  return;
                }
              },
            ),

            // ---------------- TEAM GRID ----------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: staffList.length, // +1 for Any Staff
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    // 🔵 STAFF CARD
                    final staff = staffList[index];
                    return _professionalCard(staff, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STAFF CARD ----------------
  Widget _professionalCard(Map<String, dynamic> staff, BuildContext context) {
    final String? imageUrl = staff["image"]; // 👈 adjust key if needed

    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // -------- AVATAR / IMAGE --------
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.black)
                : null,
          ),

          const SizedBox(height: 12),

          // -------- NAME --------
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
