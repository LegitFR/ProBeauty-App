import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
                        'Haircut', width, height),
                    categoryItem('assets/images/categories/spa.png', 'Spa',
                        width, height),
                    categoryItem('assets/images/categories/nail.png', 'Nails',
                        width, height),
                    categoryItem('assets/images/categories/facial.png',
                        'Facial', width, height),
                    categoryItem('assets/images/categories/haircut.png',
                        'Haircut', width, height),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),

              // === Offers carousel ===
              SizedBox(
                height: height * 0.25,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.8),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final images = [
                      'assets/images/offers/offer1.png',
                      'assets/images/offers/offer2.png',
                      'assets/images/offers/offer3.png',
                      'assets/images/offers/offer4.png',
                      'assets/images/offers/offer5.png',
                    ];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: height * 0.04),

              // === Special Offers section ===
              Text(
                "Special Offers",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: width * 0.05,
                ),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.3,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final offerImages = [
                      'assets/images/saloons/saloon1.png',
                      'assets/images/saloons/saloon2.png',
                      'assets/images/saloons/saloon2.png',
                    ];

                    return Padding(
                      padding: EdgeInsets.only(right: width * 0.04),
                      child: Container(
                        width: width * 0.65, // ~242px equivalent
                        height: height * 0.28, // ~216px equivalent
                        decoration: BoxDecoration(
                          color: AppColors.softIvory,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        child: Column(
                          children: [
                            // Top image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                offerImages[index],
                                width: double.infinity,
                                height: height * 0.135, // half height
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Bottom content
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
                                      "Zazzle Bridal Studio",
                                      style: TextStyle(
                                        fontFamily: "PoppinsSemiBold",
                                        fontSize: width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.005),
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
                                          " (1650)",
                                          style: TextStyle(
                                              fontSize: width * 0.03,
                                              color: Colors.black,
                                              fontFamily: "PoppinsRegular"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      "Anna Nagar, Chennai",
                                      style: TextStyle(
                                        fontFamily: "PoppinsRegular",
                                        fontSize: width * 0.032,
                                        color: Colors.black,
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            "Bridal Studio",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontFamily: "PoppinsRegular"),
                                          ),
                                        ),
                                        SizedBox(width: width * 0.02),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.02,
                                            vertical: height * 0.004,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.rusticSunset,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/icons/discount_tag.png',
                                                width: width * 0.035,
                                              ),
                                              SizedBox(width: width * 0.01),
                                              const Text(
                                                "Save up to 10%",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "PoppinsRegular"),
                                              ),
                                            ],
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
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.04),

              Text(
                "Recommended",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: width * 0.05,
                ),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.3,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final offerImages = [
                      'assets/images/saloons/saloon1.png',
                      'assets/images/saloons/saloon2.png',
                      'assets/images/saloons/saloon2.png',
                    ];

                    return Padding(
                      padding: EdgeInsets.only(right: width * 0.04),
                      child: Container(
                        width: width * 0.65, // ~242px equivalent
                        height: height * 0.28, // ~216px equivalent
                        decoration: BoxDecoration(
                          color: AppColors.softIvory,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        child: Column(
                          children: [
                            // Top image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                offerImages[index],
                                width: double.infinity,
                                height: height * 0.135, // half height
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Bottom content
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
                                      "Zazzle Bridal Studio",
                                      style: TextStyle(
                                        fontFamily: "PoppinsSemiBold",
                                        fontSize: width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.005),
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
                                          " (1650)",
                                          style: TextStyle(
                                              fontSize: width * 0.03,
                                              color: Colors.black,
                                              fontFamily: "PoppinsRegular"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      "Anna Nagar, Chennai",
                                      style: TextStyle(
                                        fontFamily: "PoppinsRegular",
                                        fontSize: width * 0.032,
                                        color: Colors.black,
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            "Bridal Studio",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontFamily: "PoppinsRegular"),
                                          ),
                                        ),
                                        SizedBox(width: width * 0.02),
                                      ],
                                    ),
                                  ],
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
      ),
    );
  }

  // === Category item widget ===
  Widget categoryItem(String image, String title, double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: width * 0.09,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(image),
            ),
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
