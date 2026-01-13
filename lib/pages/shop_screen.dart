// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/product_screen.dart';
import 'package:probeauty_app/pages/product_search_screen.dart';
import 'package:probeauty_app/providers/offers_provider.dart';
import 'package:probeauty_app/providers/product_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
      context.read<OfferProvider>().fetchActiveOffers(reset: true);
    });
  }

  // ---------------- Fetch Products ----------------
  // Future<void> _fetchProducts() async {
  //   if (!mounted) return;

  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {
  //     final res = await http.get(
  //       Uri.parse(_productsEndpoint),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (!mounted) return;

  //     if (res.statusCode == 200) {
  //       final Map<String, dynamic> body = json.decode(res.body);
  //       final data = body['data'];

  //       if (data is List) {
  //         _products = data.map((e) => Product.fromJson(e)).toList();

  //         if (!mounted) return;
  //         setState(() {});

  //         // fetch salon names
  //         await _fetchAllSalonNames();
  //       } else {
  //         if (!mounted) return;
  //         setState(() => _error = 'Unexpected response shape');
  //       }
  //     } else {
  //       if (!mounted) return;
  //       setState(() => _error = 'Server responded with ${res.statusCode}');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _error = 'Failed to fetch products');
  //   } finally {
  //     if (!mounted) return;
  //     setState(() => _loading = false);
  //   }
  // }

  // ---------------- Fetch All Unique Salon Names ----------------
  // Future<void> _fetchAllSalonNames() async {
  //   final uniqueSalonIds = _products
  //       .map((p) => p.salonId)
  //       .where((id) => id != null && id.isNotEmpty)
  //       .toSet();

  //   for (final salonId in uniqueSalonIds) {
  //     if (!mounted) return;

  //     if (!salonNames.containsKey(salonId)) {
  //       await _fetchSalonName(salonId!);
  //     }
  //   }

  //   if (!mounted) return;
  //   setState(() {}); // refresh UI
  // }

  // ---------------- Fetch Single Salon Name ----------------
  // Future<void> _fetchSalonName(String salonId) async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse('$_baseUrl/api/v1/salons/$salonId'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (!mounted) return;

  //     if (res.statusCode == 200) {
  //       final body = json.decode(res.body);
  //       salonNames[salonId] = body['data']?['name'] ?? 'Salon';
  //     } else {
  //       salonNames[salonId] = 'Salon';
  //     }
  //   } catch (_) {
  //     if (!mounted) return;
  //     salonNames[salonId] = 'Salon';
  //   }
  // }

  // ---------------------- UI ----------------------

  Future<void> _openProductFromOffer(
    BuildContext context,
    Map<String, dynamic> offer,
  ) async {
    try {
      final productProvider = context.read<ProductProvider>();

      final String productId = offer["productId"];
      final String salonId = offer["salonId"];

      // 1️⃣ Ensure products are loaded
      if (productProvider.products.isEmpty) {
        await productProvider.fetchProducts();
      }

      // 2️⃣ Find product by ID
      final product = productProvider.products.firstWhere(
        (p) => p.id == productId,
      );

      // 3️⃣ Get salon name (already cached by ProductProvider)
      final salonName = productProvider.salonNames[salonId] ?? "Salon";

      if (!context.mounted) return;

      // 4️⃣ Navigate (ONLY required args)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductScreen(
            product: product,
            salonName: salonName,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Failed to open product: $e");

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open product")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final productProvider = context.watch<ProductProvider>();
    final offerProvider = context.watch<OfferProvider>();
    final productOffers = offerProvider.productOffers;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  margin: EdgeInsets.only(
                      left: width * 0.035,
                      right: width * 0.035,
                      top: width * 0.035),
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
                          cursorColor: AppColors.rusticSunset,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductSearchScreen(
                                  initialQuery: value,
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: l10n.shopSearchHint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return const VoiceBottomSheet();
                            },
                          );
                        },
                        child: Image.asset(
                          'assets/images/icons/mic.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.025),

                // Categories
                SizedBox(
                  height: height * 0.11,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: width * 0.035),
                    itemCount: 4,
                    separatorBuilder: (_, __) => SizedBox(width: width * 0.035),
                    itemBuilder: (context, index) {
                      final categories = [
                        {
                          "img": 'assets/images/shop/shampoo.png',
                          "title": l10n.shopCategoryShampoo,
                        },
                        {
                          "img": 'assets/images/shop/haircolor.png',
                          "title": l10n.shopCategoryConditioner,
                        },
                        {
                          "img": 'assets/images/shop/conditioner.png',
                          "title": l10n.shopCategoryHairColour,
                        },
                        {
                          "img": 'assets/images/shop/hairoil.png',
                          "title": l10n.shopCategoryHairOil,
                        },
                      ];

                      final item = categories[index];

                      return _categoryItem(
                        context,
                        item["img"]!,
                        item["title"]!,
                        width,
                      );
                    },
                  ),
                ),

                SizedBox(height: height * 0.025),

                // Carousel banner

                offerProvider.isLoading
                    ? SizedBox(
                        height: height * 0.20,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.04),
                          itemCount: 3,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: width * 0.04),
                          itemBuilder: (_, __) => SkeletonBox(
                            width: width * 0.75,
                            height: height * 0.20,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      )
                    : productOffers.isEmpty
                        ? const SizedBox()
                        : CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.20,

                              // 🔥 prevent duplication
                              autoPlay: productOffers.length > 1,
                              enableInfiniteScroll: productOffers.length > 1,
                              enlargeCenterPage: productOffers.length > 1,

                              // 🔥 padding for single item
                              viewportFraction:
                                  productOffers.length > 1 ? 0.78 : 0.9,

                              aspectRatio: 16 / 9,
                              autoPlayInterval: const Duration(seconds: 3),
                            ),
                            items: productOffers.map((offer) {
                              final String imageUrl = offer["image"] ?? "";

                              return GestureDetector(
                                onTap: () =>
                                    _openProductFromOffer(context, offer),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        productOffers.length == 1 ? 12 : 6,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.rusticSunset,
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                offerProvider.isLoading || productOffers.isEmpty
                    ? Container()
                    : SizedBox(height: height * 0.035),

                // Title
                Padding(
                  padding:
                      EdgeInsetsGeometry.symmetric(horizontal: width * 0.035),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.shopSpecialOffers,
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: width * 0.048,
                        ),
                      ),
                      IconButton(
                        onPressed: productProvider.fetchProducts,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
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
    );
  }

  // ---------------- Build Product List ----------------
  Widget _buildSpecialOffersList(double width) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading && provider.products.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: width * 0.035),
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(width: width * 0.04),
          itemBuilder: (_, __) => Container(
            width: width * 0.55,
            decoration: BoxDecoration(
              color: AppColors.softIvory,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SkeletonBox(
                    width: double.infinity,
                    height: width * 0.32,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: width * 0.25, height: 12),
                      const SizedBox(height: 6),
                      SkeletonBox(width: width * 0.35, height: 14),
                      const SizedBox(height: 10),
                      SkeletonBox(width: width * 0.18, height: 16),
                    ],
                  ),
                ),

                const Spacer(),

                // Button skeleton
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Text(provider.error!, style: const TextStyle(color: Colors.red));
    }

    if (provider.products.isEmpty) {
      return Text(l10n.shopNoProducts);
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: width * 0.035),
      scrollDirection: Axis.horizontal,
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final p = provider.products[index];
        final image = p.images.isNotEmpty ? p.images[0] : null;
        final salonName =
            provider.salonNames[p.salonId] ?? l10n.shopLoadingSalon;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product_screen',
              arguments: {
                "product": p,
                "salonName": salonName,
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
  Widget _categoryItem(
    BuildContext context,
    String image,
    String title,
    double width,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductSearchScreen(
              initialQuery: title, // 🔥 keyword-based search
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(right: width * 0.04),
        child: Column(
          children: [
            CircleAvatar(
              radius: width * 0.085,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
              ),
            ),
          ],
        ),
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
                  maxLines: 1,
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

class VoiceBottomSheet extends StatelessWidget {
  const VoiceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.45,
      decoration: const BoxDecoration(
        color: Color(0xFFF6EEE5), // your cream background
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Close icon
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Spacer(),

          // Voice wave image
          const VoiceWaveform(),

          const SizedBox(height: 20),

          // Mic button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.orange,
              size: 28,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class VoiceWaveform extends StatefulWidget {
  const VoiceWaveform({super.key});

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final List<double> _levels = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();

    await _recorder.startRecorder(
      toFile: 'temp.aac',
      codec: Codec.aacMP4,
      audioSource: AudioSource.microphone,
    );

    _recorder.onProgress!.listen((event) {
      final double db = (event.decibels ?? -60).toDouble();

      if (mounted) {
        setState(() {
          _levels.add(db);
          if (_levels.length > 40) {
            _levels.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _levels.map((level) {
          final double height = ((level + 60).clamp(5.0, 50.0)).toDouble();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: borderRadius,
      ),
    );
  }
}
