import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/detail_screen.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/pages/salon_tabs/salon_tab_bar.dart';
import 'package:probeauty_app/pages/team_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';

class ReviewsScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final List<dynamic> staffList;
  final String address;
  final Map<String, dynamic> hours;
  final String image;
  final List<dynamic> services;

  const ReviewsScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.staffList,
    required this.address,
    required this.hours,
    required this.image,
    required this.services,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = true;
  String? _error;

  List<dynamic> _reviews = [];
  double _avgRating = 0.0;
  int _totalReviews = 0;

// NEW: star-wise count
  Map<int, int> _ratingCount = {
    5: 0,
    4: 0,
    3: 0,
    2: 0,
    1: 0,
  };

  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _submittingReview = false;

  @override
  void initState() {
    super.initState();

    _fetchReviews();

    _reviewController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ========================
  // FETCH REVIEWS
  // ========================
  Future<void> _fetchReviews() async {
    try {
      List<dynamic> allReviews = [];
      int page = 1;
      int totalPages = 1;
      const int limit = 50;

      // reset counts
      _ratingCount = {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      };

      do {
        final resp = await ApiClient.get(
          "/api/v1/reviews/salon/${widget.salonId}",
          query: {
            "page": page.toString(),
            "limit": limit.toString(),
          },
        );

        if (resp.statusCode != 200) break;

        final body = jsonDecode(resp.body);
        final List data = body["data"] ?? [];
        final pagination = body["pagination"];

        totalPages = pagination?["totalPages"] ?? 1;

        allReviews.addAll(data);

        // ⭐ Count rating distribution
        for (final r in data) {
          final int rating = r["rating"] ?? 0;
          if (_ratingCount.containsKey(rating)) {
            _ratingCount[rating] = _ratingCount[rating]! + 1;
          }
        }

        page++;
      } while (page <= totalPages);

      // 🔥 Compute real average from all reviews
      double sum = 0;
      for (final r in allReviews) {
        sum += (r["rating"] ?? 0).toDouble();
      }

      if (!mounted) return;

      setState(() {
        _reviews = allReviews;
        _totalReviews = allReviews.length;
        _avgRating = _totalReviews == 0
            ? 0.0
            : double.parse((sum / _totalReviews).toStringAsFixed(1));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _fallback();
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0 || _reviewController.text.trim().isEmpty) return;

    setState(() {
      _submittingReview = true;
    });

    try {
      final response = await ApiClient.post(
        "/api/v1/reviews",
        body: {
          "salonId": widget.salonId,
          "rating": _selectedRating,
          "comment": _reviewController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);

        // Optional: prepend new review to UI instantly
        setState(() {
          _reviews.insert(0, body["data"]);
          _selectedRating = 0;
          _reviewController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reviewsThankYou,
            ),
          ),
        );
      } else {
        final err = jsonDecode(response.body);
        _showError(err["message"] ?? "Failed to submit review");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Something went wrong. Try again.");
    } finally {
      if (!mounted) return;
      setState(() {
        _submittingReview = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _fallback() {
    setState(() {
      _avgRating = 0.0;
      _totalReviews = 0;
      _ratingCount = {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      };
      _loading = false;
      _error = "Unable to load reviews";
    });
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.softIvory,

      // ------------------------
      // APP BAR
      // ------------------------
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.salonName,
          style: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ------------------------
          // TOP TAB BAR
          // ------------------------
          SalonTabBar(
            selectedIndex: 1, // REVIEWS
            onTabTap: (index) {
              if (index == 1) return;

              // SERVICES → replace Reviews with Services
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalonDetailScreen(
                      id: widget.salonId,
                      name: widget.salonName,
                      address: widget.address,
                      image: widget.image,
                      services: widget.services,
                      salonStaffList: widget.staffList,
                      hours: widget.hours,
                    ),
                  ),
                );
                return;
              }

              // TEAM → replace Reviews with Team
              if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamScreen(
                      salonId: widget.salonId,
                      salonName: widget.salonName,
                      staffList: widget.staffList,
                      address: widget.address,
                      hours: widget.hours,
                      image: widget.image,
                      services: widget.services,
                    ),
                  ),
                );
                return;
              }

              // DETAILS → replace Reviews with Details
              if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      salonId: widget.salonId,
                      salonName: widget.salonName,
                      address: widget.address,
                      staffList: widget.staffList,
                      hours: widget.hours,
                      image: widget.image,
                      services: widget.services,
                    ),
                  ),
                );
                return;
              }
            },
          ),

          // ------------------------
          // CONTENT
          // ------------------------
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.rusticSunset,
                  ))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ------------------------
                        // OVERALL RATING + DISTRIBUTION
                        // ------------------------
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontFamily: "PoppinsSemiBold",
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: 18,
                                      color: i < _avgRating.floor()
                                          ? AppColors.rusticSunset
                                          : AppColors.greyTone,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.reviewsTotalCount(_totalReviews),
                                  style: const TextStyle(
                                    fontFamily: "PoppinsRegular",
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 24),

                            // RIGHT
                            Expanded(
                              child: Column(
                                children: List.generate(5, (index) {
                                  final star = 5 - index;
                                  return _RatingDistribution(
                                    star: star,
                                    count: _ratingCount[star] ?? 0,
                                    total: _totalReviews,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ------------------------
                        // REVIEWS HEADER
                        // ------------------------
                        Text(
                          l10n.reviewsTitle,
                          style: const TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ------------------------
                        // INFO NOTE
                        // ------------------------
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Precut guarantees that reviews with \"verified precut user\" tag have been added by registered precut users who have had an appointment with the provider. A registered precut user can add a review only after the service has been provided.",
                            style: TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ------------------------
                        // REVIEWS LIST
                        // ------------------------
                        if (_reviews.isEmpty)
                          const Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                "No reviews",
                                style: const TextStyle(
                                  fontFamily: "PoppinsMedium",
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else
                          for (final r in _reviews)
                            _reviewTile(
                              name: r["user"]?["name"] ?? "User",
                              date: _formatDate(r["createdAt"]),
                              service: r["service"]?["title"] ?? "Service",
                              review: r["comment"] ?? "",
                              rating: r["rating"] ?? 0,
                            ),

                        // ------------------------
// ADD REVIEW SECTION
// ------------------------
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.softIvory,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.reviewsAddYourReview,
                                style: const TextStyle(
                                  fontFamily: "PoppinsSemiBold",
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ⭐ STAR SELECTOR
                              Row(
                                children: List.generate(5, (index) {
                                  final starIndex = index + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRating = starIndex;
                                      });
                                    },
                                    child: Icon(
                                      Icons.star,
                                      size: 28,
                                      color: starIndex <= _selectedRating
                                          ? AppColors.rusticSunset
                                          : AppColors.greyTone,
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 14),

                              // 📝 REVIEW INPUT
                              TextField(
                                controller: _reviewController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: l10n.reviewsWriteHere,
                                  hintStyle: const TextStyle(
                                    fontFamily: "PoppinsRegular",
                                    color: Colors.black45,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.softIvory,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.rusticSunset,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: "PoppinsRegular",
                                ),
                              ),

                              const SizedBox(height: 14),

                              // 📤 SUBMIT BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submittingReview ||
                                          _selectedRating == 0 ||
                                          _reviewController.text.trim().isEmpty
                                      ? null
                                      : _submitReview,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.rusticSunset,
                                    disabledBackgroundColor:
                                        Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _submittingReview
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          l10n.reviewsSubmit,
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
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),

      // ------------------------
      // BOTTOM BAR
      // ------------------------
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.all(16),
      //   child: ElevatedButton(
      //     onPressed: () => Navigator.pop(context),
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: AppColors.rusticSunset,
      //       padding: const EdgeInsets.symmetric(vertical: 14),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //     ),
      //     child: Text(
      //       AppLocalizations.of(context)!.reviewsBookNow,
      //       style: const TextStyle(
      //         fontFamily: "PoppinsSemiBold",
      //         color: Colors.white,
      //         fontSize: 14,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  // ========================
  // HELPERS
  // ========================
  String _formatDate(String? iso) {
    if (iso == null) return "";
    final d = DateTime.tryParse(iso);
    if (d == null) return "";
    return "${d.day} ${_month(d.month)} ${d.year}";
  }

  String _month(int m) {
    final l10n = AppLocalizations.of(context)!;

    final months = [
      "",
      l10n.reviewsMonthJan,
      l10n.reviewsMonthFeb,
      l10n.reviewsMonthMar,
      l10n.reviewsMonthApr,
      l10n.reviewsMonthMay,
      l10n.reviewsMonthJun,
      l10n.reviewsMonthJul,
      l10n.reviewsMonthAug,
      l10n.reviewsMonthSep,
      l10n.reviewsMonthOct,
      l10n.reviewsMonthNov,
      l10n.reviewsMonthDec,
    ];
    return months[m];
  }

  // ========================
  // REVIEW TILE
  // ========================
  Widget _reviewTile({
    required String name,
    required String date,
    required String service,
    required String review,
    required int rating,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.softIvory,
        // borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.15),
        //     blurRadius: 6,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(name, style: const TextStyle(fontFamily: "PoppinsSemiBold")),
            const Spacer(),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.reviewsVerifiedUser,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 12,
                    color: AppColors.rusticSunset,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle,
                    size: 14, color: AppColors.rusticSunset),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(date,
            style: const TextStyle(fontFamily: "PoppinsRegular", fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              Icons.star,
              size: 16,
              color: i < rating ? AppColors.rusticSunset : AppColors.greyTone,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context)!.reviewsServiceLabel(name),
            style: const TextStyle(fontFamily: "PoppinsMedium", fontSize: 13)),
        const SizedBox(height: 6),
        Text(review, style: const TextStyle(fontFamily: "PoppinsRegular")),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.thumb_up_outlined, size: 18),
            const SizedBox(width: 12),
            const Icon(Icons.thumb_down_outlined, size: 18),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.reviewsReport,
              style:
                  const TextStyle(fontFamily: "PoppinsRegular", fontSize: 12),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              "assets/images/logos/flag.svg",
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcIn,
              ),
            ),
          ],
        )
      ]),
    );
  }
}

// ========================
// RATING DISTRIBUTION
// ========================
class _RatingDistribution extends StatelessWidget {
  final int star;
  final int count;
  final int total;

  const _RatingDistribution({
    required this.star,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$star"),
          const Icon(Icons.star, size: 14, color: AppColors.rusticSunset),
          const SizedBox(width: 6),
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : count / total,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(AppColors.rusticSunset),
            ),
          ),
          const SizedBox(width: 6),
          Text(count.toString()),
        ],
      ),
    );
  }
}
