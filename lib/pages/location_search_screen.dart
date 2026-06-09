import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../resources/AppColors.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  TextEditingController controller = TextEditingController();
  final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  List<dynamic> places = [];
  bool isLoading = false;
  Timer? _debounce;

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => places = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://places.googleapis.com/v1/places:autocomplete',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'suggestions.placePrediction.text.text,suggestions.placePrediction.placeId',
        },
        body: jsonEncode({
          "input": input,
          "includedRegionCodes": ["IN"],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          places = data["suggestions"] ?? [];
          isLoading = false;
        });

        print(data);
      } else {
        setState(() => isLoading = false);

        print(response.body);
      }
    } catch (e) {
      setState(() => isLoading = false);

      print(e);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

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
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.rusticSunset,
                              ),
                            ),
                          )
                        : controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.clear();
                                    places = [];
                                  });
                                },
                                child: const Icon(Icons.close, size: 18),
                              )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    _debounce = Timer(
                      const Duration(milliseconds: 400),
                      () {
                        searchPlaces(value);
                      },
                    );
                  },
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
                itemCount: places.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                  child: Divider(
                    height: 20,
                    thickness: 0.6,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                itemBuilder: (context, index) {
                  final place = places[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(
                          context, place["placePrediction"]["text"]["text"]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.045,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              place["placePrediction"]["text"]["text"],
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
            )
          ],
        ),
      ),
    );
  }
}
