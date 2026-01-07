import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/models/product.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const String _baseUrl = 'https://probeauty-backend.onrender.com';
  static const String _productsEndpoint = '$_baseUrl/api/v1/products';

  bool _loading = false;
  String? _error;
  List<Product> _products = [];

  // salon ID -> salon name cache
  Map<String, String> salonNames = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // ---------------- Fetch Products ----------------
  Future<void> _fetchProducts() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.get(
        Uri.parse(_productsEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(res.body);
        final data = body['data'];

        if (data is List) {
          _products = data.map((e) => Product.fromJson(e)).toList();

          if (!mounted) return;
          setState(() {});

          // fetch salon names
          await _fetchAllSalonNames();
        } else {
          if (!mounted) return;
          setState(() => _error = 'Unexpected response shape');
        }
      } else {
        if (!mounted) return;
        setState(() => _error = 'Server responded with ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to fetch products');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ---------------- Fetch All Unique Salon Names ----------------
  Future<void> _fetchAllSalonNames() async {
    final uniqueSalonIds = _products
        .map((p) => p.salonId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    for (final salonId in uniqueSalonIds) {
      if (!mounted) return;

      if (!salonNames.containsKey(salonId)) {
        await _fetchSalonName(salonId!);
      }
    }

    if (!mounted) return;
    setState(() {}); // refresh UI
  }

  // ---------------- Fetch Single Salon Name ----------------
  Future<void> _fetchSalonName(String salonId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/v1/salons/$salonId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        salonNames[salonId] = body['data']?['name'] ?? 'Salon';
      } else {
        salonNames[salonId] = 'Salon';
      }
    } catch (_) {
      if (!mounted) return;
      salonNames[salonId] = 'Salon';
    }
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(width * 0.035),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
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
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: l10n.shopSearchHint,
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

                  // Categories
                  SizedBox(
                    height: height * 0.11,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        categoryItem('assets/images/shop/shampoo.png',
                            l10n.shopCategoryShampoo, width),
                        categoryItem('assets/images/shop/haircolor.png',
                            l10n.shopCategoryConditioner, width),
                        categoryItem('assets/images/shop/conditioner.png',
                            l10n.shopCategoryHairColour, width),
                        categoryItem('assets/images/shop/hairoil.png',
                            l10n.shopCategoryHairOil, width),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.025),

                  // Carousel banner
                  CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 0.9,
                      height: height * 0.20,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: [
                      'assets/images/shop/banner1.png',
                      'assets/images/shop/banner2.png',
                      'assets/images/shop/banner3.png',
                    ].map((imagePath) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          imagePath,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: height * 0.035),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.shopSpecialOffers,
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: width * 0.045,
                        ),
                      ),
                      IconButton(
                        onPressed: _fetchProducts,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.015),

                  SizedBox(
                    height: height * 0.32,
                    child: _buildSpecialOffersList(width),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Build Product List ----------------
  Widget _buildSpecialOffersList(double width) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
        color: AppColors.rusticSunset,
      ));
    }
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red));
    }
    if (_products.isEmpty) return Text(l10n.shopNoProducts);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        final image = p.images.isNotEmpty ? p.images[0] : null;
        final salonName = salonNames[p.salonId] ?? l10n.shopLoadingSalon;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product_screen',
              arguments: {
                "product": p,
                "salonName":
                    salonName == l10n.shopLoadingSalon ? "Salon" : salonName,
              },
            );
          },
          child: specialOfferCard(
            context,
            width,
            brand: salonName,
            productName: p.title ?? 'Product',
            price: '₹${p.price ?? "-"}',
            oldPrice: '',
            discount: '',
            imageUrl: image,
          ),
        );
      },
    );
  }

  // ---------------- Category Item ----------------
  Widget categoryItem(String image, String title, double width) {
    return Padding(
      padding: EdgeInsets.only(right: width * 0.04),
      child: Column(
        children: [
          CircleAvatar(
            radius: width * 0.085,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }

  // ---------------- Product Card ----------------
  Widget specialOfferCard(
    BuildContext context,
    double width, {
    required String brand,
    required String productName,
    required String price,
    required String oldPrice,
    required String discount,
    String? imageUrl,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: width * 0.55,
      margin: EdgeInsets.only(right: width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- IMAGE + HEART ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: width * 0.32,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover, // 🔥 fills the container
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image, size: 60),
              ),
            ),
          ),

          // ---------------- TEXT CONTENT ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 13,
                    color: AppColors.rusticSunset,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // ---------------- PRICE ROW ----------------
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      discount,
                      style: const TextStyle(
                        fontFamily: "PoppinsMedium",
                        fontSize: 13,
                        color: AppColors.rusticSunset,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // ---------------- SHOP BUTTON ----------------
          Container(
            height: 40,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: const Center(
              child: Text(
                "Shop",
                style: const TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Product Model ----------------
