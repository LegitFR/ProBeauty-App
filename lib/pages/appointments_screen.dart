import "package:flutter/material.dart";
import "package:probeauty_app/resources/AppColors.dart";

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Example previous appointments data
    final previousAppointments = [
      {
        "title": "Page 3 Saloon Toni & Guy",
        "date": "Tue, 24 Sep 2024 at 11:30 am",
        "details": "60 mins | from ₹720 | Haircut and beard trim",
        "image": "assets/images/appointments/saloon_thumb_1.png",
      },
      {
        "title": "Naturals Salon",
        "date": "Mon, 2 Sep 2024 at 5:00 pm",
        "details": "45 mins | from ₹520 | Hair spa and styling",
        "image": "assets/images/appointments/saloon_thumb_1.png",
      },
      {
        "title": "Studio11 Unisex Salon",
        "date": "Wed, 14 Aug 2024 at 3:15 pm",
        "details": "90 mins | from ₹1100 | Full body massage",
        "image": "assets/images/appointments/saloon_thumb_1.png",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.04),

                // Title
                Text(
                  "Appointments",
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontFamily: "PlayfairDisplayBold",
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                // Confirmed Section
                Text(
                  "Confirmed",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: "PoppinsSemiBold",
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Confirmed Appointment Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: AppColors.softIvory,
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map Image (top half)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.asset(
                          "assets/images/appointments/map.png",
                          width: double.infinity,
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Bottom info section
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/appointment_info');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Essensuals by Toni & Guy",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontFamily: "PoppinsSemiBold",
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "Tue, 24 Sep 2024 at 11:30 am",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: "PoppinsSemiBold",
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "60 mins | from ₹720 | Haircut and beard trim",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: "PoppinsRegular",
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Get Direction Button Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.navigation_outlined,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Get directions",
                                      style: TextStyle(
                                        fontFamily: "PoppinsRegular",
                                        fontSize: screenHeight * 0.013,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.rusticSunset,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 10),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.lighterGreyTone,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.calendar_month_sharp,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Previous Section
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Previous",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: "PoppinsSemiBold",
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Multiple Previous Appointments
                Column(
                  children: previousAppointments.map((appointment) {
                    return Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              appointment["image"]!,
                              width: screenWidth * 0.22,
                              height: screenWidth * 0.22,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment["title"]!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontFamily: "PoppinsBold",
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment["date"]!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontFamily: "PoppinsMedium",
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment["details"]!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontFamily: "PoppinsRegular",
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Book Again Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.black, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ),
                              child: Text(
                                "Book Again",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontFamily: "PoppinsRegular",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
