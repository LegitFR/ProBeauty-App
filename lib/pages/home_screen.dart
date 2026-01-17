// ignore_for_file: use_build_context_synchronously

import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/explore_results_screen.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/providers/offers_provider.dart';
import 'package:probeauty_app/providers/salon_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/salon_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final salonProvider = context.read<SalonProvider>();
      final offerProvider = context.read<OfferProvider>();

      if (salonProvider.salons.isEmpty) {
        salonProvider.fetchSalons();
      }

      if (offerProvider.offers.isEmpty) {
        offerProvider.fetchActiveOffers(showLoader: true);
      } else {
        offerProvider.fetchActiveOffers(showLoader: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final salonProvider = context.watch<SalonProvider>();
    final offerProvider = context.watch<OfferProvider>();
    final offers = offerProvider.salonOffers;
    // fallback images
    final fallbackImages = [
      'assets/images/saloons/saloon1.png',
      'assets/images/saloons/saloon2.png',
      'assets/images/saloons/saloon2.png',
    ];

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Top bar ===
              Padding(
                padding: EdgeInsets.only(
                    left: width * 0.04, right: width * 0.04, top: width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logos/probeauty_app_logo.svg',
                      height: height * 0.04,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/notification");
                        },
                        child: SvgPicture.asset(
                          'assets/images/icons/notification.svg',
                          width: width * 0.05,
                          height: width * 0.05,
                        )),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),

              // === Category scroll ===
              SizedBox(
                height: height * 0.13,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: width * 0.02),
                  itemCount: 4,
                  separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
                  itemBuilder: (context, index) {
                    final categories = [
                      {
                        "img": 'assets/images/categories/haircut.png',
                        "title": l10n.categoryHaircut,
                      },
                      {
                        "img": 'assets/images/categories/spa.png',
                        "title": l10n.categorySpa,
                      },
                      {
                        "img": 'assets/images/categories/nail.png',
                        "title": l10n.categoryNails,
                      },
                      {
                        "img": 'assets/images/categories/facial.png',
                        "title": l10n.categoryFacial,
                      },
                    ];

                    final item = categories[index];

                    return categoryItem(
                      context,
                      item["img"]!,
                      item["title"]!,
                      width,
                      height,
                    );
                  },
                ),
              ),

              SizedBox(height: height * 0.03),

              // === Offers carousel ===

              offerProvider.isLoading && offers.isEmpty
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 100 &&
                            offerProvider.hasMore &&
                            !offerProvider.isLoading) {
                          offerProvider.fetchActiveOffers(showLoader: false);
                        }
                        return false;
                      },
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: height * 0.20,

                          // 🔥 prevent duplication
                          autoPlay: offers.length > 1,
                          enableInfiniteScroll: offers.length > 1,
                          enlargeCenterPage: offers.length > 1,

                          // 🔥 padding behavior
                          viewportFraction: offers.length > 1 ? 0.78 : 0.9,

                          aspectRatio: 16 / 9,
                          autoPlayInterval: const Duration(seconds: 3),
                        ),
                        items: offers.map((offer) {
                          final String imageUrl = offer["image"] ?? "";
                          final String salonId = offer["salonId"] ?? "";

                          return GestureDetector(
                            onTap: () async {
                              try {
                                if (salonId.isEmpty) return;
                                final salon =
                                    await SalonService.fetchSalonById(salonId);

                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalonDetailScreen(
                                      id: salon["id"],
                                      name: salon["name"] ?? "",
                                      address: salon["address"] ?? "",
                                      image: salon["thumbnail"] ??
                                          'assets/images/saloons/saloon1.png',
                                      services: salon["services"] ?? [],
                                      salonStaffList: salon["staff"] ?? [],
                                      hours: salon["hours"] ?? {},
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint("Failed to open salon: $e");

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Unable to open salon")),
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: offers.length == 1 ? 12 : 6,
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

              SizedBox(height: height * 0.035),

              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.04,
                  right: width * 0.04,
                ),
                child: Text(
                  l10n.homeSpecialOffers,
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: width * 0.05,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              salonProvider.isLoading && salonProvider.salons.isEmpty
                  ? SizedBox(
                      height: height * 0.315,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        itemCount: 3,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: width * 0.04),
                        itemBuilder: (_, __) => Container(
                          width: width * 0.65,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.softIvory,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(
                                width: double.infinity,
                                height: height * 0.135,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              const SizedBox(height: 10),
                              SkeletonBox(width: width * 0.4, height: 14),
                              const SizedBox(height: 8),
                              SkeletonBox(width: width * 0.25, height: 12),
                              const SizedBox(height: 8),
                              SkeletonBox(width: width * 0.5, height: 12),
                            ],
                          ),
                        ),
                      ),
                    )
                  : buildSalonList(
                      width,
                      height,
                      fallbackImages,
                      salonProvider,
                    ),

              SizedBox(height: height * 0.04),

              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.04,
                  right: width * 0.04,
                ),
                child: Text(
                  l10n.homeRecommended,
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: width * 0.05,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              salonProvider.isLoading && salonProvider.salons.isEmpty
                  ? SizedBox(
                      height: height * 0.315,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        itemCount: 3,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: width * 0.04),
                        itemBuilder: (_, __) => Container(
                          width: width * 0.65,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.softIvory,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(
                                width: double.infinity,
                                height: height * 0.135,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              const SizedBox(height: 10),
                              SkeletonBox(width: width * 0.4, height: 14),
                              const SizedBox(height: 8),
                              SkeletonBox(width: width * 0.25, height: 12),
                              const SizedBox(height: 8),
                              SkeletonBox(width: width * 0.5, height: 12),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: buildSalonList(
                        width,
                        height,
                        fallbackImages,
                        salonProvider,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // === Salon Card List (Horizontal)
  Widget buildSalonList(
    double width,
    double height,
    List images,
    SalonProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    const BorderRadius cardRadius = BorderRadius.all(
      Radius.circular(16),
    );

    const BorderRadius imageRadius = BorderRadius.only(
      topLeft: Radius.circular(11),
      topRight: Radius.circular(11),
    );

    return SizedBox(
      height: height * 0.315,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 100 &&
              provider.hasMore) {
            provider.fetchSalons();
          }
          return false;
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: provider.salons.length,
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          itemBuilder: (context, index) {
            final salon = provider.salons[index];

            final String id = salon["id"] ?? "";
            final String name = salon["name"] ?? "Salon";
            final String address = salon["address"] ?? "Unknown location";
            final List services =
                salon["services"] is List ? salon["services"] : [];
            final List salonStaffList =
                salon["staff"] is List ? salon["staff"] : [];
            final img = salon["thumbnail"] ?? images[index % images.length];
            final hours = salon["hours"];

            // 🔥 Trigger rating fetch (cached → safe)
            provider.fetchSalonRating(id);

            // 🔥 Read cached rating
            final ratingData = provider.getSalonRating(id);
            final double avgRating = ratingData?["avgRating"] ?? 0.0;
            final int totalReviews = ratingData?["totalReviews"] ?? 0;

            return GestureDetector(
              onTap: () {
                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalonDetailScreen(
                      id: id,
                      name: name,
                      address: address,
                      image: img,
                      services: services,
                      salonStaffList: salonStaffList,
                      hours: hours,
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
                    borderRadius: cardRadius,
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Column(
                    children: [
                      // IMAGE
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                          right: 6,
                          top: 6,
                        ),
                        child: ClipRRect(
                          borderRadius: imageRadius,
                          child: Image(
                            image: img.startsWith('http')
                                ? NetworkImage(img)
                                : AssetImage(img) as ImageProvider,
                            width: double.infinity,
                            height: height * 0.135,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
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
                              // NAME
                              Text(
                                name,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: "PoppinsSemiBold",
                                  fontSize: width * 0.04,
                                ),
                              ),

                              SizedBox(height: height * 0.005),

                              // ⭐ RATING + COUNT
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: width * 0.035,
                                      color: i < avgRating.floor()
                                          ? AppColors.rusticSunset
                                          : AppColors.greyTone,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Text(
                                    "($totalReviews)",
                                    style: TextStyle(
                                      fontSize: width * 0.03,
                                      fontFamily: "PoppinsRegular",
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: height * 0.005),

                              // ADDRESS
                              Text(
                                address.contains('\n') ? address : '$address\n',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: width * 0.032,
                                ),
                              ),

                              SizedBox(height: height * 0.008),

                              // TAGS
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
                                          SizedBox(width: width * 0.045),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // === Category item widget ===
  Widget categoryItem(
    BuildContext context,
    String image,
    String title,
    double width,
    double height,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExploreResultsScreen(
              serviceText: title,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: Column(
          children: [
            SizedBox(
              width: width * 0.18,
              height: width * 0.18,
              child: ClipOval(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.012),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
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
