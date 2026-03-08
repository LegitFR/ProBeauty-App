// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/detail_screen.dart';
import 'package:probeauty_app/pages/reviews_screen.dart';
import 'package:probeauty_app/pages/salon_tabs/salon_tab_bar.dart';
import 'package:probeauty_app/pages/select_services_screen.dart';
import 'package:probeauty_app/pages/team_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';

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
    // ✅ Use cache first
    if (_ratingCache.containsKey(widget.id)) {
      final cached = _ratingCache[widget.id]!;
      setState(() {
        _avgRating = cached["avgRating"];
        _totalReviews = cached["totalReviews"];
        _ratingLoading = false;
      });
      return;
    }

    try {
      int page = 1;
      int totalPages = 1;
      double totalRatingSum = 0;
      int totalReviews = 0;

      do {
        final response = await ApiClient.get(
          "/api/v1/reviews/salon/${widget.id}",
          query: {
            "page": page.toString(),
            "limit": "20",
          },
        );

        if (response.statusCode != 200) break;

        final body = jsonDecode(response.body);
        final List reviews = body["data"] ?? [];
        final pagination = body["pagination"];

        totalPages = pagination?["totalPages"] ?? 1;

        for (final r in reviews) {
          final rating = (r["rating"] ?? 0).toDouble();
          totalRatingSum += rating;
          totalReviews++;
        }

        page++;
      } while (page <= totalPages);

      final avg = totalReviews == 0
          ? 0.0
          : double.parse((totalRatingSum / totalReviews).toStringAsFixed(1));

      // ✅ Cache result
      _ratingCache[widget.id] = {
        "avgRating": avg,
        "totalReviews": totalReviews,
      };

      setState(() {
        _avgRating = avg;
        _totalReviews = totalReviews;
        _ratingLoading = false;
      });
    } catch (_) {
      _setRatingFallback();
    }
  }

  String _openStatusText() {
    final now = DateTime.now();
    final weekday = _weekdayKey(now.weekday);
    final today = widget.hours[weekday];

    if (today == null) return "Closed today";

    return "Open until ${today["close"]}";
  }

  String _weekdayKey(int day) {
    const map = {
      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };
    return map[day]!;
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
    final height = size.height;
    final bool hasServices = widget.services.isNotEmpty;

    return Scaffold(
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
                    _openStatusText(),
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 14,
                      color: _openStatusText() == "Closed today"
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SalonTabBar(
                    selectedIndex: 0,
                    onTabTap: (index) {
                      if (index == 0) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            if (index == 1) {
                              return ReviewsScreen(
                                salonId: widget.id,
                                salonName: widget.name,
                                staffList: widget.salonStaffList,
                                address: widget.address,
                                hours: widget.hours,
                                image: widget.image,
                                services: widget.services,
                              );
                            }
                            if (index == 2) {
                              return TeamScreen(
                                salonId: widget.id,
                                salonName: widget.name,
                                staffList: widget.salonStaffList,
                                address: widget.address,
                                hours: widget.hours,
                                image: widget.image,
                                services: widget.services,
                              );
                            }
                            return DetailScreen(
                              salonId: widget.id,
                              salonName: widget.name,
                              address: widget.address,
                              staffList: widget.salonStaffList,
                              hours: widget.hours,
                              image: widget.image,
                              services: widget.services,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const Divider(thickness: 1),
                  const SizedBox(height: 14),

                  // ---------------------------
                  // SERVICES LIST
                  // ---------------------------
                  for (var s in widget.services) ...[
                    _serviceTile(
                      title: s["title"] ?? "",
                      subtitle: l10n.salonServiceDuration(s["durationMinutes"]),
                      price: "₹${s["price"]}",
                      category: s["category"] ?? "Featured",
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

      bottomNavigationBar: SafeArea(
        child: Container(
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
                              image: widget.image,
                              salonStaffList: widget.salonStaffList,
                              initialCategory: "Featured",
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
    required String category,
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
                    image: widget.image,
                    salonStaffList: widget.salonStaffList,
                    initialCategory: category,
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
