import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.035),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== Search Bar ====
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.035, vertical: height * 0.01),
                  decoration: BoxDecoration(
                    color: AppColors.softIvory,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 22),
                      SizedBox(width: width * 0.025),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontFamily: "PoppinsRegular",
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/icons/mic.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.025),

                // ==== Category Scroll ====
                SizedBox(
                  height: height * 0.11,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoryItem(
                          'assets/images/shop/shampoo.png', 'Shampoo', width),
                      categoryItem('assets/images/shop/haircolor.png',
                          'Hair Colour', width),
                      categoryItem('assets/images/shop/conditioner.png',
                          'Conditioner', width),
                      categoryItem(
                          'assets/images/shop/hairoil.png', 'Hair Oil', width),
                      categoryItem(
                          'assets/images/shop/hairoil.png', 'Hair Oil', width),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.025),

                // ==== Placeholder for Carousel ====
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
                    'assets/images/shop/banner1.png',
                    'assets/images/shop/banner2.png',
                    'assets/images/shop/banner3.png',
                  ].map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: height * 0.035),

                // ==== Special Offers ====
                Text(
                  "Special offers",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: width * 0.045,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: height * 0.015),

                SizedBox(
                  height: height * 0.32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      specialOfferCard(
                        context,
                        width,
                        brand: "De Fabulous",
                        productName:
                            "De Fabulous Marula Oil Shampoo with Quinoa ultimate...",
                        price: "₹1,490",
                        oldPrice: "₹1,620",
                        discount: "(8% off)",
                        image: "assets/images/shop/product1.png",
                      ),
                      specialOfferCard(
                        context,
                        width,
                        brand: "GK Hair",
                        productName:
                            "GK Hair Moisturizing Color Protection Conditioner (300ml)",
                        price: "₹1,827",
                        oldPrice: "₹2,150",
                        discount: "(15% off)",
                        image: "assets/images/shop/product1.png",
                      ),
                      specialOfferCard(
                        context,
                        width,
                        brand: "GK Hair",
                        productName:
                            "GK Hair Moisturizing Color Protection Conditioner (300ml)",
                        price: "₹1,827",
                        oldPrice: "₹2,150",
                        discount: "(15% off)",
                        image: "assets/images/shop/product1.png",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Category Item Widget ===
  Widget categoryItem(String image, String title, double width) {
    return Padding(
      padding: EdgeInsets.only(right: width * 0.04),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: width * 0.085,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(image),
            ),
          ),
          SizedBox(height: width * 0.015),
          Text(
            title,
            style: TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: width * 0.032,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // === Special Offer Card Widget ===
  Widget specialOfferCard(
    BuildContext context,
    double width, {
    required String brand,
    required String productName,
    required String price,
    required String oldPrice,
    required String discount,
    required String image,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_screen');
      },
      child: Container(
        width: width * 0.5,
        margin: EdgeInsets.only(right: width * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Product Image & Heart Icon ===
            Stack(
              children: [
                Container(
                  height: width * 0.3,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.favorite_border, color: Colors.grey[600]),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: width * 0.015),
                  Text(
                    brand,
                    style: TextStyle(
                      color: AppColors.rusticSunset,
                      fontSize: width * 0.03,
                      fontFamily: "PoppinsRegular",
                    ),
                  ),
                  SizedBox(height: width * 0.008),
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.03,
                      fontFamily: "PoppinsRegular",
                    ),
                  ),
                  SizedBox(height: width * 0.01),
                  Row(
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.037,
                          fontFamily: "PoppinsSemiBold",
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                      Text(
                        oldPrice,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: width * 0.03,
                          fontFamily: "PoppinsRegular",
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: width * 0.005),
                      Text(
                        discount,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // === Select Size Button ===
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: width * 0.022),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "Select Size",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.033,
                  fontFamily: "PoppinsMedium",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
