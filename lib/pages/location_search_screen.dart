import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../resources/AppColors.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  TextEditingController controller = TextEditingController();

  List<Map<String, String>> locations = [
    {"title": "Chennai", "subtitle": "Tamil Nadu, India"},
    {
      "title": "Chennai International Airport (MAA)",
      "subtitle": "Chennai - Trichy Highway, Tambaram"
    },
    {
      "title": "Chennai Central Railway Station",
      "subtitle": "Periamet, Park Town"
    },
    {"title": "Chennai Central", "subtitle": "Tamil Nadu"},
    {
      "title": "Chennai Trade Centre – Nandambakkam",
      "subtitle": "Ramapuram, Nandambakkam"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 🔙 Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Location",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔍 Search Field (MATCHED STYLE)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.softIvory,
                  border: Border.all(color: Colors.black, width: 1.4),
                ),
                child: TextField(
                  controller: controller,
                  cursorColor: AppColors.rusticSunset,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/images/icons/location_icon.svg",
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                      ),
                    ),
                    hintText: "Search location",
                    hintStyle: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      color: Colors.black,
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() => controller.clear());
                            },
                            child: const Icon(Icons.close, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // 👉 call your existing function
                  Navigator.pop(context, "Current Location");
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // 🎯 Icon circle background
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: AppColors.rusticSunset.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: AppColors.rusticSunset,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📍 Text
                      const Text(
                        "Current location",
                        style: TextStyle(
                          fontFamily: "PoppinsMedium",
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Divider(
                thickness: 0.6,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            // 📍 Results
            Expanded(
              child: ListView.separated(
                itemCount: locations.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                  child: Divider(
                    height: 20,
                    thickness: 0.6,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                itemBuilder: (context, index) {
                  final item = locations[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, item["title"]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.045,
                        vertical: 10, // 👈 better spacing
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📍 Icon
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: SvgPicture.asset(
                              "assets/images/icons/location_icon.svg",
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 📄 Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    fontFamily: "PoppinsMedium",
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                    height: 4), // 👈 more breathing space
                                Text(
                                  item["subtitle"]!,
                                  style: const TextStyle(
                                    fontFamily: "PoppinsRegular",
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
