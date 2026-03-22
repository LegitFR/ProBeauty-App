import 'package:flutter/material.dart';
import '../resources/AppColors.dart';

class TreatmentSearchScreen extends StatefulWidget {
  const TreatmentSearchScreen({super.key});

  @override
  State<TreatmentSearchScreen> createState() => _TreatmentSearchScreenState();
}

class _TreatmentSearchScreenState extends State<TreatmentSearchScreen> {
  TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> treatments = [
    {"title": "Hair & styling", "icon": Icons.content_cut},
    {"title": "Nails", "icon": Icons.back_hand},
    {"title": "Eyebrows & eyelashes", "icon": Icons.remove_red_eye},
    {"title": "Massage", "icon": Icons.spa},
    {"title": "Barbering", "icon": Icons.face},
    {"title": "Hair removal", "icon": Icons.clean_hands},
    {"title": "Facials & skincare", "icon": Icons.self_improvement},
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
                    "Search",
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

            // 🔍 Search Field
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
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    hintText: "Search services",
                    hintStyle: TextStyle(
                      fontFamily: "PoppinsMedium",
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ❌ No results text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: const Column(
                children: const [
                  Text(
                    "We didn't find a match",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Clear your search or select from our top categories below",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 Treatments Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: const Text(
                "Treatments",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📍 Treatments List
            Expanded(
              child: ListView.separated(
                itemCount: treatments.length,
                separatorBuilder: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                  child: Divider(
                    height: 20,
                    thickness: 0.6,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
                itemBuilder: (context, index) {
                  final item = treatments[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, item["title"]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.045,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          // 🔥 Icon Box
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: AppColors.softIvory,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.black26, width: 1.2),
                            ),
                            child: Center(
                              child: Icon(
                                item["icon"],
                                color: AppColors.rusticSunset,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // 🔤 Title
                          Expanded(
                            child: Text(
                              item["title"],
                              style: const TextStyle(
                                fontFamily: "PoppinsMedium",
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
