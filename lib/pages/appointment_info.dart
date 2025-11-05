import "package:flutter/material.dart";
import "package:probeauty_app/resources/AppColors.dart";

class AppointmentInfo extends StatelessWidget {
  const AppointmentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Action tiles
    final List<Map<String, dynamic>> tiles = [
      {
        "icon": Icons.calendar_today_rounded,
        "title": "Add to Calendar",
        "desc": "Set yourself a reminder",
      },
      {
        "icon": Icons.route_rounded,
        "title": "Manage appointment",
        "desc": "Reschedule or Cancel ",
      },
      {
        "icon": Icons.navigation_rounded,
        "title": "Getting there",
        "desc": "Anna nagar, Chennai",
      },
      {
        "icon": Icons.vertical_shades_rounded,
        "title": "Venue details",
        "desc": "Toni & Guy essensuals anna nagar",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Essensuals by Toni & Guy",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "PoppinsSemiBold",
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Image with share button (no padding) =====
            Stack(
              children: [
                ClipRRect(
                  child: Image.asset(
                    "assets/images/appointments/saloon_thumb_1.png",
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.softIvory,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ===== Content below image (with padding for text only) =====
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.03),

                  // Confirmed Tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.rusticSunset,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Confirmed",
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontFamily: "PoppinsMedium",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Date + Time Section
                  Text(
                    "Tomorrow 24 Sep 2024 at\n11:30 am",
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "1 hour duration",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: "PoppinsRegular",
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // ===== Action Tiles Section (no padding) =====
            Column(
              children: List.generate(tiles.length, (index) {
                final tile = tiles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.softIvory,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.softIvory,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          tile["icon"],
                          color: AppColors.rusticSunset,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tile["title"],
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontFamily: "PoppinsSemiBold",
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tile["desc"],
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                fontFamily: "PoppinsRegular",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            SizedBox(height: screenHeight * 0.05),

            // ===== Overview Section =====
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Text(
                "Overview",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontFamily: "PoppinsSemiBold",
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ===== Overview Tiles (no padding) =====
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.softIvory,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Men’s Hair Cut",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: "PoppinsSemiBold",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "\$720",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: "PoppinsSemiBold",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "1 hour",
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontFamily: "PoppinsRegular",
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Taxes",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontFamily: "PoppinsRegular",
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "\$50",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontFamily: "PoppinsRegular",
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.softIvory,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: "PoppinsSemiBold",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "\$770",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontFamily: "PoppinsSemiBold",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pay at venue",
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          fontFamily: "PoppinsRegular",
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "\$770",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontFamily: "PoppinsRegular",
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
