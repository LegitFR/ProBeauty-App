import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> salons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalons();
  }

  Future<void> fetchSalons() async {
    try {
      final url = Uri.parse(
          "https://probeauty-backend.onrender.com/api/v1/salons?page=1");

      final response = await http.get(url);

      print("SALON STATUS: ${response.statusCode}");
      print("SALON BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          salons = data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Salon Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // fallback images
    final fallbackImages = [
      'assets/images/saloons/saloon1.png',
      'assets/images/saloons/saloon2.png',
      'assets/images/saloons/saloon2.png',
    ];

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Top bar ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logos/full_logo.png',
                    height: height * 0.05,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icons/notification.png',
                        width: width * 0.07,
                        height: width * 0.07,
                      ),
                      SizedBox(width: width * 0.04),
                      Image.asset(
                        'assets/images/icons/qr.png',
                        width: width * 0.07,
                        height: width * 0.07,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),

              // === Category scroll ===
              SizedBox(
                height: height * 0.13,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    categoryItem('assets/images/categories/haircut.png',
                        l10n.categoryHaircut, width, height),
                    categoryItem('assets/images/categories/spa.png',
                        l10n.categorySpa, width, height),
                    categoryItem('assets/images/categories/nail.png',
                        l10n.categoryNails, width, height),
                    categoryItem('assets/images/categories/facial.png',
                        l10n.categoryFacial, width, height),
                    categoryItem('assets/images/categories/haircut.png',
                        l10n.categoryHaircut, width, height),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),

              // === Offers carousel ===
              CarouselSlider(
                options: CarouselOptions(
                  height: height * 0.20,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                items: [
                  'assets/images/offers/offer1.png',
                  'assets/images/offers/offer2.png',
                  'assets/images/offers/offer3.png',
                ].map((imagePath) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: height * 0.04),

              // === Special Offers section ===
              Text(
                l10n.homeSpecialOffers,
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: width * 0.05,
                ),
              ),
              SizedBox(height: height * 0.02),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildSalonList(width, height, fallbackImages),

              SizedBox(height: height * 0.04),

              Text(
                l10n.homeRecommended,
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: width * 0.05,
                ),
              ),
              SizedBox(height: height * 0.02),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildSalonList(width, height, fallbackImages),
            ],
          ),
        ),
      ),
    );
  }

  // === Salon Card List (Horizontal)
  Widget buildSalonList(double width, double height, List images) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: height * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: salons.length,
        itemBuilder: (context, index) {
          final salon = salons[index];

          final String id = salon["id"] ?? "id";
          final String name = salon["name"] ?? "Salon";
          final String address = salon["address"] ?? "Unknown location";
          final List services =
              salon["services"] is List ? salon["services"] : [];
          final List salonStaffList =
              salon["staff"] is List ? salon["staff"] : [];
          final img = images[index % images.length];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SalonDetailScreen(
                    id: id,
                    name: name,
                    address: address,
                    rating: 4.5,
                    reviews: 1200,
                    image: img,
                    services: services,
                    salonStaffList: salonStaffList,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: width * 0.04),
              child: Container(
                width: width * 0.65,
                decoration: BoxDecoration(
                  color: AppColors.softIvory,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        img,
                        width: double.infinity,
                        height: height * 0.135,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: height * 0.01,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: "PoppinsSemiBold",
                                fontSize: width * 0.04,
                              ),
                            ),
                            SizedBox(height: height * 0.005),

                            // Fake stars
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    Icons.star,
                                    size: width * 0.035,
                                    color: starIndex < 4
                                        ? AppColors.rusticSunset
                                        : AppColors.greyTone,
                                  ),
                                ),
                                SizedBox(width: width * 0.01),
                                Text(
                                  "(1200)",
                                  style: TextStyle(
                                    fontSize: width * 0.03,
                                    fontFamily: "PoppinsRegular",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.005),

                            Text(
                              address,
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                fontSize: width * 0.032,
                              ),
                            ),

                            SizedBox(height: height * 0.008),

                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.004,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lighterGreyTone,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    l10n.homeSalonLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: "PoppinsRegular",
                                    ),
                                  ),
                                ),

                                SizedBox(width: width * 0.02),

                                // 👇 THIS is mandatory
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.02,
                                      vertical: height * 0.004,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.rusticSunset,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/icons/discount_tag.png',
                                          width: width * 0.035,
                                        ),
                                        SizedBox(width: width * 0.01),

                                        // 👇 text constrained properly
                                        Expanded(
                                          child: Text(
                                            l10n.homeSaveUpto("10"),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.03,
                                              fontFamily: "PoppinsRegular",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // === Category item widget ===
  Widget categoryItem(String image, String title, double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: Column(
        children: [
          CircleAvatar(
            radius: width * 0.09,
            backgroundImage: AssetImage(image),
          ),
          SizedBox(height: height * 0.012),
          Text(
            title,
            style: TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: width * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
