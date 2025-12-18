import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final String salonName;

  const ProductScreen({
    super.key,
    required this.product,
    required this.salonName,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedSize = 0;
  int selectedRating = 0;

  // 🔥 Cart quantity synced with backend
  int quantity = 0;

  final sizes = ["180ml", "250ml", "450ml", "1000ml"];
  int currentImageIndex = 0;

  final String baseUrl = "https://probeauty-backend.onrender.com";
  bool _cartUpdating = false; // to prevent spamming requests
  bool _favUpdating = false;
  bool _isFavourited = false;

  @override
  void initState() {
    super.initState();
    _loadInitialCartQuantity();
    _checkFavouriteStatus();
  }

  Future<void> _checkFavouriteStatus() async {
    final productId = widget.product.id;
    if (productId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) return;

      final url = Uri.parse("$baseUrl/api/v1/favourites/check/$productId");

      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final fav = data["data"]?["isFavourited"] ?? false;
        if (mounted) setState(() => _isFavourited = fav);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavourite() async {
    if (_favUpdating) return;

    final productId = widget.product.id;
    if (productId == null) return;

    setState(() => _favUpdating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login first")),
        );
        return;
      }

      http.Response resp;

      if (_isFavourited) {
        final url = Uri.parse("$baseUrl/api/v1/favourites/$productId");
        resp = await http.delete(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (resp.statusCode == 200) {
          setState(() => _isFavourited = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Removed from favourites"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final url = Uri.parse("$baseUrl/api/v1/favourites");
        resp = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"productId": productId}),
        );

        if (resp.statusCode == 201) {
          setState(() => _isFavourited = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Added to favourites"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _favUpdating = false);
  }

  Future<void> _loadInitialCartQuantity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        print("⚠ No token found; cart remains local only (quantity = 0)");
        return;
      }

      final url = Uri.parse("$baseUrl/api/v1/cart");
      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 GET CART status: ${resp.statusCode}");
      print("📥 GET CART body: ${resp.body}");

      if (resp.statusCode == 200) {
        final jsonBody = jsonDecode(resp.body);
        final data = jsonBody["data"];
        if (data == null || data["cart"] == null) return;

        final cart = data["cart"];
        final List items = cart["cartItems"] ?? [];

        final productId = widget.product.id;
        if (productId == null) return;

        int backendQty = 0;
        for (final item in items) {
          if (item["productId"] == productId) {
            backendQty = (item["quantity"] ?? 0) as int;
            break;
          }
        }

        if (mounted) {
          setState(() {
            quantity = backendQty;
          });
        }
      } else {
        print("❌ Failed to load cart: ${resp.statusCode}");
      }
    } catch (e) {
      print("❌ Error loading cart: $e");
    }
  }

  Future<void> _incrementQuantity() async {
    if (_cartUpdating) return;
    final productId = widget.product.id;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product ID missing"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newQty = quantity + 1;

    setState(() {
      _cartUpdating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠ Please login to use cart"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _cartUpdating = false;
        });
        return;
      }

      http.Response resp;

      if (quantity == 0) {
        // First time adding → POST /cart/items
        final url = Uri.parse("$baseUrl/api/v1/cart/items");
        final body = {
          "productId": productId,
          "quantity": newQty,
        };

        print("📤 POST CART ITEM body: $body");

        resp = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      } else {
        // Already in cart → PATCH /cart/items/:productId
        final url = Uri.parse("$baseUrl/api/v1/cart/items/$productId");
        final body = {
          "quantity": newQty,
        };

        print("📤 PATCH CART ITEM body: $body");

        resp = await http.patch(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      }

      print("📥 CART + STATUS: ${resp.statusCode}");
      print("📥 CART + BODY: ${resp.body}");

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        if (mounted) {
          setState(() {
            quantity = newQty;
          });
        }
      } else {
        String msg = "Failed to update cart";
        try {
          final j = jsonDecode(resp.body);
          if (j is Map && j["message"] != null) {
            msg = j["message"].toString();
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ CART + ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating cart: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _cartUpdating = false;
      });
    }
  }

  Future<void> _decrementQuantity() async {
    if (_cartUpdating) return;
    if (quantity == 0) return;

    final productId = widget.product.id;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product ID missing"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newQty = quantity - 1;

    setState(() {
      _cartUpdating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠ Please login to use cart"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _cartUpdating = false;
        });
        return;
      }

      http.Response resp;

      if (newQty > 0) {
        // Update quantity → PATCH
        final url = Uri.parse("$baseUrl/api/v1/cart/items/$productId");
        final body = {
          "quantity": newQty,
        };

        print("📤 PATCH CART ITEM (decrement) body: $body");

        resp = await http.patch(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );
      } else {
        // Quantity becomes 0 → DELETE
        final url = Uri.parse("$baseUrl/api/v1/cart/items/$productId");

        print("📤 DELETE CART ITEM productId: $productId");

        resp = await http.delete(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );
      }

      print("📥 CART - STATUS: ${resp.statusCode}");
      print("📥 CART - BODY: ${resp.body}");

      if (resp.statusCode == 200) {
        if (mounted) {
          setState(() {
            quantity = newQty;
          });
        }
      } else {
        String msg = "Failed to update cart";
        try {
          final j = jsonDecode(resp.body);
          if (j is Map && j["message"] != null) {
            msg = j["message"].toString();
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ CART - ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating cart: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _cartUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final String salonName = widget.salonName;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(color: AppColors.softIvory),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${product.price ?? ""}",
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "View price details",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              // Right: Quantity selector + Cart icon
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
                          onPressed: _cartUpdating ? null : _decrementQuantity,
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
                          onPressed: _cartUpdating ? null : _incrementQuantity,
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/cart");
                    },
                    child: Container(
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
                // ==========================
                //    IMAGE CAROUSEL
                // ==========================
                CarouselSlider(
                  options: CarouselOptions(
                    height: height * 0.40,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() => currentImageIndex = index);
                    },
                  ),
                  items:
                      (product.images.isNotEmpty ? product.images : [""]).map(
                    (imgUrl) {
                      return Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: imgUrl.isNotEmpty
                            ? Image.network(
                                imgUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 100),
                              )
                            : const Icon(Icons.image, size: 120),
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 10),

                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentImageIndex == index ? 10 : 7,
                      height: currentImageIndex == index ? 10 : 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex == index
                            ? AppColors.rusticSunset
                            : Colors.black26,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // === Brand Name ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: width * 0.035,
                            color: AppColors.rusticSunset,
                          ),
                        ),
                        SizedBox(height: height * 0.005),

                        // === Product Title ===
                        Text(
                          product.title ?? "Product Name",
                          style: TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: width * 0.038,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _toggleFavourite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                          color: AppColors.softIvory,
                        ),
                        child: Icon(
                          _isFavourited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavourited ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.008),

                // Rating Row
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
                    ...List.generate(
                      4,
                      (index) => const Icon(
                        Icons.star,
                        color: AppColors.rusticSunset,
                        size: 18,
                      ),
                    ),
                    const Icon(
                      Icons.star_half,
                      color: AppColors.rusticSunset,
                      size: 18,
                    ),
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

                // Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${product.price ?? ""}",
                      style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: width * 0.045,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: width * 0.015),
                    const Text(
                      "₹1,620",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: width * 0.015),
                    const Text(
                      "(8% off)",
                      style: TextStyle(
                        fontFamily: "PoppinsMedium",
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  "Inclusive Of All Taxes",
                  style: TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: width * 0.023,
                    color: Colors.black,
                  ),
                ),

                // SizedBox(height: height * 0.025),

                // Size selector
                // Text(
                //   "Select Size",
                //   style: TextStyle(
                //     fontFamily: "PoppinsRegular",
                //     fontSize: width * 0.035,
                //     color: Colors.black,
                //   ),
                // ),
                // SizedBox(height: height * 0.012),

                // Row(
                //   children: List.generate(sizes.length, (index) {
                //     final isSelected = selectedSize == index;
                //     return GestureDetector(
                //       onTap: () => setState(() => selectedSize = index),
                //       child: Container(
                //         margin: EdgeInsets.only(right: width * 0.025),
                //         padding: EdgeInsets.symmetric(
                //             horizontal: width * 0.035, vertical: width * 0.02),
                //         decoration: BoxDecoration(
                //           color: isSelected
                //               ? AppColors.rusticSunset
                //               : Colors.transparent,
                //           borderRadius: BorderRadius.circular(15),
                //           border: Border.all(
                //             color: isSelected ? Colors.transparent : Colors.black,
                //           ),
                //         ),
                //         child: Text(
                //           sizes[index],
                //           style: TextStyle(
                //             fontFamily: "PoppinsRegular",
                //             fontSize: width * 0.032,
                //             color: isSelected ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ),
                //     );
                //   }),
                // ),
                // SizedBox(height: height * 0.02),

                // Offers (static)
                _offersSection(width, height),

                SizedBox(height: height * 0.02),

                // Sold by
                Row(
                  children: [
                    Text(
                      "Sold by : ",
                      style: TextStyle(
                        fontSize: width * 0.032,
                        fontFamily: "PoppinsRegular",
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "RELIANCE RETAIL LIMITED",
                      style: TextStyle(
                        fontSize: width * 0.032,
                        fontFamily: "PoppinsMedium",
                        color: AppColors.rusticSunset,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),

                // Feature cards
                _featureRow(width, height),

                SizedBox(height: height * 0.03),

                // Delivery options
                _deliverySection(width, height),

                SizedBox(height: height * 0.03),

                // Description
                sectionTile(
                  "Product description",
                  product.title ??
                      "This shampoo helps nourish and repair damaged hair with Marula oil and Quinoa protein.",
                ),

                SizedBox(height: height * 0.01),

                // Key features
                sectionTile(
                  "Key features and benefits",
                  "• Repairs damaged hair\n• Adds shine\n• Sulfate-free formula",
                ),

                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _offersSection(double width, double height) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.035,
      ),
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
              _offerChip(width, Icons.local_offer_outlined, "6 Offers"),
              SizedBox(width: width * 0.03),
              _offerChip(width, Icons.card_giftcard_outlined, "Free Gifts"),
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _offerChip(double width, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.rusticSunset),
          SizedBox(width: width * 0.015),
          Text(
            text,
            style: TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: width * 0.028,
              color: AppColors.rusticSunset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(double width, double height) {
    return Row(
      children: [
        Expanded(
          child: _featureCard(
            width,
            height,
            "assets/images/icons/authentic.png",
            "Authentic Product",
          ),
        ),
        Expanded(
          child: _featureCard(
            width,
            height,
            "assets/images/icons/easy_return.png",
            "Easy Return",
          ),
        ),
      ],
    );
  }

  Widget _featureCard(double width, double height, String icon, String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.01),
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
          Image.asset(icon, height: height * 0.05),
          SizedBox(height: height * 0.01),
          Text(
            text,
            style: TextStyle(
              fontFamily: "PoppinsRegular",
              fontSize: width * 0.03,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliverySection(double width, double height) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.025),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black,
                  ),
                  const Text(
                    "4000023",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    "Change",
                    style: TextStyle(color: Colors.black),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Row(
            children: const [
              Icon(
                Icons.local_shipping_outlined,
                size: 22,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text(
                "Free delivery - Get it by Sat, 25 Jan",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
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
              padding: const EdgeInsets.all(16),
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
