import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/detail_screen.dart';
import 'package:probeauty_app/pages/reviews_screen.dart';
import 'package:probeauty_app/pages/select_services_screen.dart';
import 'package:probeauty_app/pages/team_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SalonDetailScreen extends StatefulWidget {
  final String id;
  final String name;
  final String address;
  final String image;

  final List<dynamic> services;
  final List<dynamic> salonStaffList;
  final Map<String, dynamic> hours;

  const SalonDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.services,
    required this.salonStaffList,
    required this.hours,
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  int selectedTab = 0;
  double _avgRating = 0.0;
  int _totalReviews = 0;
  bool _ratingLoading = true;
  static final Map<String, Map<String, dynamic>> _ratingCache = {};

  void _setRatingFallback() {
    if (!_ratingCache.containsKey(widget.id)) {
      setState(() {
        _avgRating = 0.0;
        _totalReviews = 0;
        _ratingLoading = false;
      });
    }
  }

  Future<void> _fetchSalonRating() async {
    // ✅ 1. Check cache first
    if (_ratingCache.containsKey(widget.id)) {
      final cached = _ratingCache[widget.id]!;
      setState(() {
        _avgRating = cached["avgRating"];
        _totalReviews = cached["totalReviews"];
        _ratingLoading = false;
      });
      return;
    }

    // ✅ 2. Fetch only if not cached
    try {
      final url = Uri.parse(
        "https://probeauty-backend.onrender.com/api/v1/reviews/salon/${widget.id}?page=1&limit=1",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final avg = (body["averageRating"] ?? 0).toDouble();
        final total = body["pagination"]?["total"] ?? 0;

        // ✅ Save to cache
        _ratingCache[widget.id] = {
          "avgRating": avg,
          "totalReviews": total,
        };

        setState(() {
          _avgRating = avg;
          _totalReviews = total;
          _ratingLoading = false;
        });
      } else {
        _setRatingFallback();
      }
    } catch (_) {
      _setRatingFallback();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSalonRating();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final bool hasServices = widget.services.isNotEmpty;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: AppBar(
          backgroundColor: AppColors.softIvory,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          centerTitle: true,
          title: Text(
            widget.name,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // -------------------------------
              // TOP IMAGE
              // -------------------------------
              SizedBox(
                height: height * 0.25,
                width: double.infinity,
                child: Stack(
                  children: [
                    Image(
                      image: widget.image.startsWith('http')
                          ? NetworkImage(widget.image)
                          : AssetImage(widget.image) as ImageProvider,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Icon(Icons.share, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),

              // -------------------------------
              // DETAILS
              // -------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + HEART
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                            color: AppColors.softIvory,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_border),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // RATINGS
                    _ratingLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.rusticSunset,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                _avgRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: "PoppinsSemiBold",
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 18,
                                  color: i < _avgRating.floor()
                                      ? AppColors.rusticSunset
                                      : AppColors.greyTone,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "($_totalReviews)",
                                style: const TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),

                    const SizedBox(height: 8),

                    Text(
                      widget.address,
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      l10n.salonOpenUntil("10:00pm"),
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------
                    // TAB BAR
                    // ---------------------------
                    SizedBox(
                      height: 45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TabButton(title: l10n.salonTabServices, index: 0),
                            _TabButton(title: l10n.salonTabReviews, index: 1),
                            _TabButton(title: l10n.salonTabTeam, index: 2),
                            _TabButton(title: l10n.salonTabDetails, index: 3),
                            _TabButton(title: l10n.salonTabGiftCards, index: 4),
                          ],
                        ),
                      ),
                    ),

                    const Divider(thickness: 1),
                    const SizedBox(height: 14),

                    // ---------------------------
                    // SERVICES LIST
                    // ---------------------------
                    for (var s in widget.services) ...[
                      _serviceTile(
                        title: s["title"] ?? "",
                        subtitle:
                            l10n.salonServiceDuration(s["durationMinutes"]),
                        price: "₹${s["price"]}",
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ---------------------------
        // FIXED BOTTOM BAR
        // ---------------------------

        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.softIvory,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.salonServicesAvailable(widget.services.length),
                // "${widget.services.length} services available",
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton(
                onPressed: hasServices
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectServicesScreen(
                              salonId: widget.id,
                              salonName: widget.name,
                              services: widget.services,
                              salonStaffList: widget.salonStaffList,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasServices
                      ? AppColors.rusticSunset
                      : Colors.grey.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: hasServices ? 2 : 0,
                ),
                child: Text(
                  "Book now",
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    color: hasServices ? Colors.white : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------
  // SERVICE TILE
  // ---------------------------------------
  Widget _serviceTile({
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: "PoppinsSemiBold", fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        color: Colors.black54)),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(
                        fontFamily: "PoppinsSemiBold", fontSize: 15)),
              ],
            ),
          ),

          // BOOK BUTTON
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectServicesScreen(
                    salonId: widget.id,
                    salonName: widget.name,
                    services: widget.services,
                    salonStaffList: widget.salonStaffList,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "BOOK",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------
// TAB BUTTON WIDGET
// ---------------------------------------
class _TabButton extends StatelessWidget {
  final String title;
  final int index;

  const _TabButton({required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SalonDetailScreenState>();
    final bool isActive = state?.selectedTab == index;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                salonId: state!.widget.id,
                salonName: state.widget.name,
                staffList: state.widget.salonStaffList,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamScreen(
                salonName: state!.widget.name,
                staffList: state.widget.salonStaffList,
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                salonName: state!.widget.name,
                address: state.widget.address,
                hours: state.widget.hours,
              ),
            ),
          );
        } else {
          state?.setState(() {
            state.selectedTab = index;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 13,
            color: isActive ? AppColors.rusticSunset : Colors.black54,
          ),
        ),
      ),
    );
  }
}
