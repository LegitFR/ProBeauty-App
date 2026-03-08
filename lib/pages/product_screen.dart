// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/models/cart_item.dart';
import 'package:probeauty_app/providers/cart_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:probeauty_app/services/api_client.dart';
import 'package:provider/provider.dart';

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

  final sizes = ["180ml", "250ml", "450ml", "1000ml"];
  int currentImageIndex = 0;

  bool _cartUpdating = false;
  bool _favUpdating = false;
  bool _isFavourited = false;

  List<Map<String, dynamic>> _availableOffers = [];
  bool _offersLoading = true;
  bool _showAllOffers = false;

  @override
  void initState() {
    super.initState();

    _fetchApplicableOffers();
    _checkFavouriteStatus();
  }

  Future<void> _fetchApplicableOffers() async {
    try {
      final res = await ApiClient.get(
        "/api/v1/offers/public/active",
        query: {"limit": "20"},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body["data"] ?? [];

        final productId = widget.product.id;

        _availableOffers = data
            .where((offer) {
              // // 🟢 Salon-wide offers apply to all
              // if (offer["offerType"] == "salon") return true;

              // 🟢 Product-specific offers
              if (offer["offerType"] == "product") {
                return offer["productId"] == productId;
              }

              return false;
            })
            .cast<Map<String, dynamic>>()
            .toList();
      }
    } catch (e) {
      debugPrint("Offer fetch error: $e");
    } finally {
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  Future<void> _checkFavouriteStatus() async {
    final productId = widget.product.id;
    if (productId == null) return;

    try {
      final resp = await ApiClient.get(
        "/api/v1/favourites/check/$productId",
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
      late final response;

      if (_isFavourited) {
        response = await ApiClient.delete(
          "/api/v1/favourites/$productId",
        );

        if (response.statusCode == 200) {
          if (mounted) setState(() => _isFavourited = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Removed from favourites"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        response = await ApiClient.post(
          "/api/v1/favourites",
          body: {"productId": productId},
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (mounted) setState(() => _isFavourited = true);
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
    } finally {
      if (mounted) setState(() => _favUpdating = false);
    }
  }

  Future<void> _incrementQuantity(int quantity, int stock) async {
    if (_cartUpdating) return;

    if (quantity >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No more stock available")),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final productId = widget.product.id;

    if (productId == null) return;

    setState(() => _cartUpdating = true);

    final msg = quantity == 0
        ? await cart.addItem(productId: productId)
        : await cart.increaseQty(
            productId: productId,
            currentQty: quantity,
          );

    if (msg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    if (mounted) setState(() => _cartUpdating = false);
  }

  Future<void> _decrementQuantity(int quantity) async {
    if (_cartUpdating) return;

    if (quantity == 0) return;

    final cart = context.read<CartProvider>();
    final productId = widget.product.id;

    if (productId == null) return;

    setState(() => _cartUpdating = true);

    final msg = await cart.decreaseQty(
      productId: productId,
      currentQty: quantity,
    );

    if (msg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    if (mounted) setState(() => _cartUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final cart = context.watch<CartProvider>();

    final item = cart.items.firstWhere(
      (e) => e.productId == widget.product.id,
      orElse: () => CartItemModel(
        id: "",
        productId: "",
        title: "",
        price: 0,
        quantity: 0,
      ),
    );

    final quantity = item.quantity;
    final int stock = product.quantity ?? 0;

    final String salonName = widget.salonName;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final double price = (product.price ?? 0).toDouble();
    final double totalPrice = price * quantity;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      bottomNavigationBar: SafeArea(
        child: Container(
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
                    quantity == 0
                        ? "Add to Cart"
                        : "₹${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    quantity == 0
                        ? "Select quantity to see price"
                        : "₹${price.toStringAsFixed(2)} × $quantity",
                    style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 11,
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
                          onPressed: _cartUpdating
                              ? null
                              : () => _decrementQuantity(quantity),
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
                          onPressed: (_cartUpdating || quantity >= stock)
                              ? null
                              : () => _incrementQuantity(quantity, stock),
                          icon: Icon(
                            Icons.add,
                            color: quantity >= stock
                                ? Colors.white38
                                : Colors.white,
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
      ),
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/cart");
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        "assets/images/icons/cart_icon.svg",
                        width: 26,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),

                      // 🔥 Cart Count Badge
                      if (cartProvider.totalItems > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.rusticSunset,
                            ),
                            child: Text(
                              cartProvider.totalItems.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontFamily: "PoppinsSemiBold",
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
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
                items: (product.images.isNotEmpty ? product.images : [""]).map(
                  (imgUrl) {
                    return SizedBox.expand(
                      child: imgUrl.isNotEmpty
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover, // 🔥 KEY FIX
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
                        _isFavourited ? Icons.favorite : Icons.favorite_border,
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

              SizedBox(height: height * 0.025),

              // Size selector
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

              // Offers (static)
              _offersSection(width, height),
              SizedBox(height: height * 0.02),

              if (_showAllOffers)
                Column(
                  children: _availableOffers.map((offer) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softIvory,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer,
                              color: AppColors.rusticSunset, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer["title"],
                                  style: const TextStyle(
                                    fontFamily: "PoppinsSemiBold",
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer["description"] ?? "",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            offer["discountType"] == "percentage"
                                ? "${offer["discountValue"]}% OFF"
                                : "₹${offer["discountValue"]} OFF",
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              color: AppColors.rusticSunset,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

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
                    salonName,
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
              _offerChip(width, Icons.local_offer_outlined,
                  "${_availableOffers.length} Offers"),
              // SizedBox(width: width * 0.03),
              // _offerChip(width, Icons.card_giftcard_outlined, "Free Gifts"),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() => _showAllOffers = !_showAllOffers);
            },
            child: Row(
              children: [
                Text(
                  _showAllOffers ? "Hide" : "View all",
                  style: TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: width * 0.03,
                  ),
                ),
                Icon(
                  _showAllOffers
                      ? Icons.keyboard_arrow_up
                      : Icons.arrow_forward_ios,
                  size: 14,
                ),
              ],
            ),
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
