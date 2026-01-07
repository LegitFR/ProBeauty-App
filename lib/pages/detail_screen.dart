import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class DetailScreen extends StatelessWidget {
  final String salonName;
  final String address;
  final Map<String, dynamic> hours;

  const DetailScreen({
    super.key,
    required this.salonName,
    required this.address,
    required this.hours,
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
            // -------- SALON INFO CARD --------
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
                            style: const TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: Colors.green,
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

        // ---------------- BOTTOM BAR ----------------
        // bottomNavigationBar: Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   decoration: const BoxDecoration(
        //     border: Border(top: BorderSide(color: Colors.black12)),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const Text(
        //         "Services available",
        //         style: TextStyle(
        //           fontFamily: "PoppinsRegular",
        //           fontSize: 13,
        //         ),
        //       ),
        //       ElevatedButton(
        //         onPressed: () {},
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: AppColors.rusticSunset,
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //         child: const Text(
        //           "Book now",
        //           style: TextStyle(
        //             fontFamily: "PoppinsSemiBold",
        //             color: Colors.white,
        //             fontSize: 14,
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
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
