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
  int _currentProductOfferIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productProvider = context.read<ProductProvider>();
      final offerProvider = context.read<OfferProvider>();

      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts();
      }

      // Silent refresh for offers
      if (offerProvider.offers.isEmpty) {
        offerProvider.fetchActiveOffers(showLoader: true);
      } else {
        offerProvider.fetchActiveOffers(showLoader: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to load product details.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final offerProvider = context.watch<OfferProvider>();
    final productOffers = offerProvider.productOffers;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        bottom: true,
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
                        controller: _searchController,
                        style: const TextStyle(
                          fontFamily: "PoppinsRegular",
                        ),
                        cursorColor: AppColors.rusticSunset,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (value.trim().isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter a product name.",
                                ),
                              ),
                            );

                            return;
                          }

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
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     showModalBottomSheet(
                    //       context: context,
                    //       isScrollControlled: true,
                    //       backgroundColor: Colors.transparent,
                    //       builder: (context) {
                    //         return const VoiceBottomSheet();
                    //       },
                    //     );
                    //   },
                    //   child: Image.asset(
                    //     'assets/images/icons/mic.png',
                    //     width: 20,
                    //     height: 20,
                    //   ),
                    // ),
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

              offerProvider.isLoading && productOffers.isEmpty
                  ? SizedBox(
                      height: height * 0.20,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
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
                      ? const Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: Center(
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.local_offer_outlined,
                                  color: Colors.black45,
                                  size: 38,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No active offers available right now.",
                                  style: TextStyle(
                                    fontFamily: "PoppinsRegular",
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                    notification.metrics.maxScrollExtent -
                                        100 &&
                                offerProvider.hasMore &&
                                !offerProvider.isLoading) {
                              offerProvider.fetchActiveOffers(
                                  showLoader: false);
                            }
                            return false;
                          },
                          child: CarouselSlider(
                            options: CarouselOptions(
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentProductOfferIndex = index;
                                });
                              },

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
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

              const SizedBox(height: 12),
              _buildProductOfferIndicator(productOffers.length),

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
                    // IconButton(
                    //   onPressed: productProvider.fetchProducts,
                    //   icon: const Icon(Icons.refresh),
                    // ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.015),

              SizedBox(
                height: width * 0.74,
                child: _buildSpecialOffersList(width),
              ),

              SizedBox(height: height * 0.015),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductOfferIndicator(int count) {
    if (count <= 1) {
      return Center(
        child: Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.rusticSunset,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == _currentProductOfferIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.rusticSunset : Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // ---------------- Build Product List ----------------
  Widget _buildSpecialOffersList(double width) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading && provider.products.isEmpty) {
      return SizedBox(
        height: 300,
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
      return const Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Colors.black45,
              ),
              SizedBox(height: 14),
              Text(
                "Unable to load products.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Please try again later.",
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
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.black45,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.shopNoProducts,
              style: const TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
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
            price: '€${p.price ?? "-"}',
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
              style: TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: width * 0.03,
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
      height: width * 0.75, // 🔥 FIX: give fixed height
      margin: EdgeInsets.only(right: width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        // ❌ REMOVE mainAxisSize.min
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Padding(
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/saloons/error.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 60),
              ),
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 13,
                    color: AppColors.rusticSunset,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (oldPrice.isNotEmpty)
                      Text(
                        oldPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black45,
                        ),
                      ),
                    const SizedBox(width: 6),
                    if (discount.isNotEmpty)
                      Expanded(
                        // 🔥 FIX: prevents overflow
                        child: Text(
                          discount,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 THIS IS THE MAIN FIX
          const Spacer(),

          /// BUTTON (no navigation change)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Shop",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    color: Colors.white,
                    fontSize: 14,
                  ),
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
    final status = await Permission.microphone.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Microphone permission is required for voice search.",
          ),
        ),
      );
      return;
    }

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
