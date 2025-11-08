import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedSize = 0;
  int selectedRating = 0;
  int quantity = 1;

  final sizes = ["180ml", "250ml", "450ml", "1000ml"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: AppColors.softIvory,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // === Price Info ===
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "₹1,490",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "View price details",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            // === Quantity Controls + Delete ===
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.rusticSunset,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "PoppinsMedium",
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.rusticSunset,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    "assets/images/icons/cart_icon.svg",
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: SvgPicture.asset(
              'assets/images/icons/cart_icon.svg',
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Product Image ===
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: height * 0.32,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/shop/product1.png',
                          height: height * 0.25,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/images/icons/share.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // === Product Info ===
              Text(
                "De Fabulous",
                style: TextStyle(
                  fontFamily: "PoppinsMedium",
                  fontSize: width * 0.035,
                  color: AppColors.rusticSunset,
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                "De Fabulous Marula Oil Shampoo with Quinoa ultimate repair for Damaged Hair (250ml)",
                style: TextStyle(
                  fontFamily: "PoppinsMedium",
                  fontSize: width * 0.038,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: height * 0.008),

              Row(
                children: [
                  Text(
                    "4.5  ",
                    style: TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: width * 0.03,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.star,
                      color: AppColors.rusticSunset, size: 18),
                  const Icon(Icons.star,
                      color: AppColors.rusticSunset, size: 18),
                  const Icon(Icons.star,
                      color: AppColors.rusticSunset, size: 18),
                  const Icon(Icons.star,
                      color: AppColors.rusticSunset, size: 18),
                  const Icon(Icons.star_half,
                      color: AppColors.rusticSunset, size: 18),
                  SizedBox(width: width * 0.015),
                  Text(
                    "(90) Rate this product",
                    style: TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: width * 0.03,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.015),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹1,490",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: width * 0.045,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: width * 0.015),
                  Text(
                    "₹1,620",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: width * 0.032,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: width * 0.015),
                  Text(
                    "(8% off)",
                    style: TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: width * 0.03,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                "Inclusive Of All Taxes",
                style: TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: width * 0.023,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: height * 0.025),

              // === Size Selector ===
              Text(
                "Select Size",
                style: TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: width * 0.035,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.012),

              Row(
                children: List.generate(sizes.length, (index) {
                  final isSelected = selectedSize == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSize = index),
                    child: Container(
                      margin: EdgeInsets.only(right: width * 0.025),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.035, vertical: width * 0.02),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.rusticSunset
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.black,
                        ),
                      ),
                      child: Text(
                        sizes[index],
                        style: TextStyle(
                          fontFamily: "PoppinsRegular",
                          fontSize: width * 0.032,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: height * 0.02),

              // === Seller Info Section ===
              // === Offers and Seller Info Section ===
              Container(
                margin: EdgeInsets.only(top: height * 0.02),
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: width * 0.035),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.rusticSunset.withOpacity(0.5),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.025,
                              vertical: width * 0.015),
                          decoration: BoxDecoration(
                            color: AppColors.softIvory,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_offer_outlined,
                                  size: 16, color: AppColors.rusticSunset),
                              SizedBox(width: width * 0.015),
                              Text(
                                "6 Offers",
                                style: TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: width * 0.028,
                                  color: AppColors.rusticSunset,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.025),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.025,
                              vertical: width * 0.015),
                          decoration: BoxDecoration(
                            color: AppColors.softIvory,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard_outlined,
                                  size: 16, color: AppColors.rusticSunset),
                              SizedBox(width: width * 0.015),
                              Text(
                                "Free Gifts",
                                style: TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: width * 0.028,
                                  color: AppColors.rusticSunset,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "View all",
                          style: TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: width * 0.03,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.black),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),
              Row(
                children: [
                  Text(
                    "Sold by : ",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: width * 0.032,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "RELIANCE RETAIL LIMITED",
                    style: TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: width * 0.032,
                      color: AppColors.rusticSunset,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: width * 0.02),
                      padding: EdgeInsets.symmetric(vertical: height * 0.025),
                      decoration: BoxDecoration(
                        color: AppColors.softIvory,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset("assets/images/icons/authentic.png"),
                          SizedBox(height: height * 0.01),
                          Text(
                            "Authentic Product",
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: width * 0.03,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: width * 0.02),
                      padding: EdgeInsets.symmetric(vertical: height * 0.025),
                      decoration: BoxDecoration(
                        color: AppColors.softIvory,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset("assets/images/icons/easy_return.png"),
                          SizedBox(height: height * 0.01),
                          Text(
                            "Easy Return",
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: width * 0.03,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),

              // === Expandable Sections ===
              // === Delivery Options Section ===
              Container(
                margin: EdgeInsets.only(top: height * 0.025),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.softIvory,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.black.withOpacity(1), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Top Row ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Delivery Options",
                              style: TextStyle(
                                fontFamily: "PoppinsMedium",
                                fontSize: width * 0.035,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: width * 0.015),
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: Colors.black),
                            Text(
                              "4000023",
                              style: TextStyle(
                                fontFamily: "PoppinsRegular",
                                fontSize: width * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Change",
                              style: TextStyle(
                                fontFamily: "PoppinsMedium",
                                fontSize: width * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 12, color: Colors.black),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.02),

                    // === Bottom Row (Delivery Info) ===
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03, vertical: width * 0.025),
                      decoration: BoxDecoration(
                        color: AppColors.softIvory,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 22, color: Colors.black),
                          SizedBox(width: width * 0.02),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Free delivery ",
                                  style: TextStyle(
                                    fontFamily: "PoppinsMedium",
                                    fontSize: width * 0.03,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "- Get it by Sat, 25 Jan",
                                  style: TextStyle(
                                    fontFamily: "PoppinsRegular",
                                    fontSize: width * 0.03,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),

              sectionTile("Product description",
                  "This shampoo helps nourish and repair damaged hair with Marula oil and Quinoa protein."),
              SizedBox(height: height * 0.01),
              sectionTile("Key features and benefits",
                  "• Repairs damaged hair\n• Adds shine and smoothness\n• Sulfate-free formula"),

              // === Rate This Product Section ===
              Container(
                margin: EdgeInsets.only(top: height * 0.03),
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: height * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.rusticSunset.withOpacity(0.25),
                      Colors.white.withOpacity(0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rate this Product",
                      style: TextStyle(
                        fontFamily: "PoppinsMedium",
                        fontSize: width * 0.035,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isSelected = index < selectedRating;
                        return IconButton(
                          onPressed: () =>
                              setState(() => selectedRating = index + 1),
                          icon: Icon(
                            isSelected ? Icons.star : Icons.star_border,
                            color: AppColors.rusticSunset,
                            size: width * 0.08,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // === Seller Info Small Feature Icon ===
  Widget sellerFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppColors.rusticSunset, size: 24),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: "PoppinsRegular",
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget sectionTile(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: "PoppinsRegular",
              color: Colors.black,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                content,
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
