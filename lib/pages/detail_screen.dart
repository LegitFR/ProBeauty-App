import 'package:flutter/material.dart';
import 'package:probeauty_app/pages/reviews_screen.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/pages/salon_tabs/salon_tab_bar.dart';
import 'package:probeauty_app/pages/team_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class DetailScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String address;
  final List<dynamic> staffList;
  final Map<String, dynamic> hours;
  final String image;
  final List<dynamic> services;

  const DetailScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.address,
    required this.staffList,
    required this.hours,
    required this.image,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
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
            SalonTabBar(
              selectedIndex: 3, // DETAILS
              onTabTap: (index) {
                if (index == 3) return;

                // SERVICES → replace Details with Services (root)
                if (index == 0) {
                  Navigator.pushAndRemoveUntil(
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
                    (route) => route.isFirst,
                  );

                  return;
                }

                // REVIEWS → replace Details with Reviews
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewsScreen(
                        salonId: salonId,
                        salonName: salonName,
                        address: address,
                        staffList: staffList,
                        hours: hours,
                        image: image,
                        services: services,
                      ),
                    ),
                  );
                  return;
                }

                // TEAM → replace Details with Team
                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamScreen(
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
              },
            ),

            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softIvory,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ICON
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salonName,
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: const TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _openStatusText(),
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: _openStatusText() == "Closed today"
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BUTTON
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rusticSunset,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Get directions",
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // -------- OPENING TIMES --------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Opening Times",
                      style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildOpeningTimes(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  List<Widget> _buildOpeningTimes() {
    final daysOrder = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ];

    return daysOrder.map((day) {
      final dayData = hours[day];
      final open = dayData?["open"] ?? "--";
      final close = dayData?["close"] ?? "--";

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.green),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Text(
                _capitalize(day),
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              "$open – $close",
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _openStatusText() {
    final now = DateTime.now();
    final weekday = _weekdayKey(now.weekday);
    final today = hours[weekday];

    if (today == null) return "Closed today";

    return "Open until ${today["close"]}";
  }

  String _weekdayKey(int day) {
    const map = {
      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };
    return map[day]!;
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
