import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/resources/AppColors.dart';

class ReviewsScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final double rating;
  final int totalReviews;

  const ReviewsScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.rating,
    required this.totalReviews,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final String baseUrl = "https://probeauty-backend.onrender.com";

  bool _loading = true;
  String? _error;

  List<dynamic> _reviews = [];
  double _avgRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  // ========================
  // FETCH REVIEWS
  // ========================
  Future<void> _fetchReviews() async {
    try {
      final url = Uri.parse(
        "$baseUrl/api/v1/reviews/salon/${widget.salonId}?page=1&limit=20",
      );

      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        setState(() {
          _reviews = body["data"] ?? [];
          _avgRating = (body["averageRating"] ?? widget.rating).toDouble();
          _totalReviews = body["pagination"]?["total"] ?? widget.totalReviews;
          _loading = false;
        });
      } else {
        _fallback();
      }
    } catch (_) {
      _fallback();
    }
  }

  void _fallback() {
    setState(() {
      _avgRating = widget.rating;
      _totalReviews = widget.totalReviews;
      _loading = false;
      _error = "Unable to load reviews";
    });
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const _TopTab(title: "SERVICES", isActive: false)),
                  const _TopTab(title: "REVIEWS", isActive: true),
                  const _TopTab(title: "TEAM", isActive: false),
                  const _TopTab(title: "GIFT CARDS", isActive: false),
                  const _TopTab(title: "DETAILS", isActive: false),
                ],
              ),
            ),
          ),

          // ------------------------
          // CONTENT
          // ------------------------
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
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
                                  "$_totalReviews reviews",
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
                                children: const [
                                  _RatingDistribution(star: 5, count: 1190),
                                  _RatingDistribution(star: 4, count: 15),
                                  _RatingDistribution(star: 3, count: 15),
                                  _RatingDistribution(star: 2, count: 10),
                                  _RatingDistribution(star: 1, count: 0),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ------------------------
                        // REVIEWS HEADER
                        // ------------------------
                        const Text(
                          "Reviews",
                          style: TextStyle(
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
                        for (final r in _reviews)
                          _reviewTile(
                            name: r["user"]?["name"] ?? "User",
                            date: _formatDate(r["createdAt"]),
                            service: r["service"]?["title"] ?? "Service",
                            review: r["comment"] ?? "",
                            rating: r["rating"] ?? 0,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rusticSunset,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Book now",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
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
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
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
            const Row(
              children: const [
                Text(
                  "Verified precut user",
                  style: TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 12,
                    color: AppColors.rusticSunset,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.check_circle,
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
        Text("Service: $service",
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
            const Text(
              "Report",
              style: TextStyle(fontFamily: "PoppinsRegular", fontSize: 12),
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
// TOP TAB
// ========================
class _TopTab extends StatelessWidget {
  final String title;
  final bool isActive;

  const _TopTab({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "PoppinsSemiBold",
          fontSize: 13,
          color: isActive ? AppColors.rusticSunset : Colors.black54,
        ),
      ),
    );
  }
}

// ========================
// RATING DISTRIBUTION
// ========================
class _RatingDistribution extends StatelessWidget {
  final int star;
  final int count;

  const _RatingDistribution({required this.star, required this.count});

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
              value: count / 1200,
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
