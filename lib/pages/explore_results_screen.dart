// pages/explore_results_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/pages/select_services_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

/// ExploreResultsScreen
/// - Services now come directly from /salons/search
/// - Booking integration added: POST /api/v1/bookings
class ExploreResultsScreen extends StatefulWidget {
  final String? serviceText;
  final String? dateText;
  final String? timeText;
  final String? locationText;

  final double? maxPrice;
  final List<String>? venueTypes;
  final List<String>? sortOptions;
  final double? latitude;
  final double? longitude;

  const ExploreResultsScreen({
    super.key,
    this.serviceText,
    this.dateText,
    this.timeText,
    this.locationText,
    this.maxPrice,
    this.venueTypes,
    this.sortOptions,
    this.latitude,
    this.longitude,
  });

  @override
  State<ExploreResultsScreen> createState() => _ExploreResultsScreenState();
}

class _ExploreResultsScreenState extends State<ExploreResultsScreen> {
  final String baseUrl = "https://probeauty-backend.onrender.com";

  int _page = 1;
  final int _limit = 10;
  bool _isLoadingPage = false;
  bool _hasMore = true;

  List<SalonModel> salons = [];

  final ScrollController _scrollController = ScrollController();

  bool _initialLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSalonsPage(page: _page);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 250 &&
          !_isLoadingPage &&
          _hasMore) {
        _fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, String> _buildSearchParams({
    required int page,
    required int limit,
  }) {
    final p = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if ((widget.serviceText ?? '').isNotEmpty) {
      p['service'] = widget.serviceText!;
    }
    if ((widget.locationText ?? '').isNotEmpty) {
      p['location'] = widget.locationText!;
    }
    if ((widget.dateText ?? '').isNotEmpty) {
      p['date'] = widget.dateText!;
    }
    if ((widget.timeText ?? '').isNotEmpty) {
      p['time'] = widget.timeText!.toLowerCase();
    }
    if (widget.maxPrice != null) {
      p['maxPrice'] = widget.maxPrice!.toStringAsFixed(0);
    }
    if (widget.sortOptions != null && widget.sortOptions!.isNotEmpty) {
      p['sortBy'] = widget.sortOptions!.first;
    }
    if (widget.venueTypes != null && widget.venueTypes!.isNotEmpty) {
      p['venueType'] = widget.venueTypes!.first.toLowerCase();
    }
    if (widget.latitude != null && widget.longitude != null) {
      p['latitude'] = widget.latitude!.toString();
      p['longitude'] = widget.longitude!.toString();
    }

    return p;
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore) return;
    _page += 1;
    await _fetchSalonsPage(page: _page);
  }

  Future<void> _fetchSalonsPage({required int page}) async {
    setState(() {
      _isLoadingPage = true;
      _error = null;
    });

    try {
      final params = _buildSearchParams(page: page, limit: _limit);
      final uri = Uri.parse("$baseUrl/api/v1/salons/search")
          .replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'] ?? [];

        final List<SalonModel> fetched =
            data.map<SalonModel>((s) => SalonModel.fromJson(s)).toList();

        setState(() {
          salons.addAll(fetched);
          _hasMore = fetched.length >= _limit;
          _initialLoading = false;
          _isLoadingPage = false;
        });
      } else {
        setState(() {
          _error = "Failed to fetch salons: ${response.statusCode}";
          _isLoadingPage = false;
          _initialLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoadingPage = false;
        _initialLoading = false;
      });
    }
  }

  Future<void> _refreshSearch() async {
    setState(() {
      _page = 1;
      salons.clear();
      _hasMore = true;
      _initialLoading = true;
      _error = null;
    });
    await _fetchSalonsPage(page: _page);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: AppBar(
          leading: Container(),
          backgroundColor: AppColors.softIvory,
          leadingWidth: 0,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.045, vertical: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.softIvory,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/icons/search_icon.svg",
                          height: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.serviceText ?? "Haircut & styling",
                                style: const TextStyle(
                                  fontFamily: "PoppinsMedium",
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  widget.dateText,
                                  widget.timeText,
                                  widget.locationText,
                                ]
                                    .where(
                                        (e) => e != null && e.trim().isNotEmpty)
                                    .join(" | "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: "PoppinsRegular",
                                  fontSize: 12.5,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          "assets/images/icons/audio_icon.svg",
                          height: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Row(
              //       children: [
              //         _filterIcon(),
              //         const SizedBox(width: 10),
              //         _filterChip("Sort"),
              //         const SizedBox(width: 10),
              //         _filterChip("Max price"),
              //         const SizedBox(width: 10),
              //         _filterChip("Venue type"),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 12),
              Expanded(
                child: _initialLoading
                    ? _buildSkeletonList()
                    : _error != null
                        ? _buildError()
                        : RefreshIndicator(
                            onRefresh: _refreshSearch,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.045, vertical: 8),
                              itemCount: salons.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < salons.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: SalonCard(
                                      salon: salons[index],
                                      dateText: widget.dateText,
                                      timeText: widget.timeText,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.rusticSunset,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(_error!, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      itemBuilder: (c, i) => _skeletonCard(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 4,
    );
  }

  Widget _skeletonCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Widget _filterIcon() {
  //   return Container(
  //     padding: const EdgeInsets.all(6),
  //     decoration: BoxDecoration(
  //       border: Border.all(),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: SvgPicture.asset(
  //       "assets/images/icons/filter_icon.svg",
  //       height: 20,
  //     ),
  //   );
  // }

  // Widget _filterChip(String label) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //     decoration: BoxDecoration(
  //       border: Border.all(),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         Text(label),
  //         const Icon(Icons.arrow_drop_down),
  //       ],
  //     ),
  //   );
  // }
}

class SalonModel {
  final String id;
  final String name;
  final String? address;
  final String? venueType;
  final double? averageRating;
  final String? thumbnail;
  final List<ServiceModel> services;

  SalonModel({
    required this.id,
    required this.name,
    this.address,
    this.venueType,
    this.thumbnail,
    this.averageRating,
    required this.services,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    final List servicesJson = json['services'] ?? [];

    return SalonModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "Salon",
      address: json['address'],
      venueType: json['venueType'],
      thumbnail: json['thumbnail'],
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : 0.0,
      services: servicesJson
          .map<ServiceModel>((s) => ServiceModel.fromJson(s))
          .toList(),
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final int? durationMinutes;
  final double? price;
  final List<StaffModel> staff;

  ServiceModel({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.price,
    required this.staff,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final List staffJson = json['staff'] ?? [];
    return ServiceModel(
      id: json['id'] ?? "",
      title: json['title'] ?? "",
      durationMinutes: json['durationMinutes'] != null
          ? (json['durationMinutes'] as num).toInt()
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      staff: staffJson.map<StaffModel>((s) => StaffModel.fromJson(s)).toList(),
    );
  }
}

class StaffModel {
  final String id;
  final String? userId;

  StaffModel({required this.id, this.userId});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? "",
      userId: json['userId']?.toString(),
    );
  }
}

class SalonRatingCache {
  static final Map<String, SalonRating> _cache = {};

  static SalonRating? get(String salonId) => _cache[salonId];

  static void set(String salonId, SalonRating rating) {
    _cache[salonId] = rating;
  }
}

class SalonRating {
  final double avgRating;
  final int totalReviews;

  SalonRating({
    required this.avgRating,
    required this.totalReviews,
  });
}

class SalonCard extends StatefulWidget {
  final SalonModel salon;
  final String? dateText;
  final String? timeText;

  const SalonCard({
    super.key,
    required this.salon,
    this.dateText,
    this.timeText,
  });

  @override
  State<SalonCard> createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard> {
  double? _avgRating;
  int _totalReviews = 0;
  bool _loadingRating = true;
  final Map<String, bool> _openingServices = {};

  @override
  void initState() {
    super.initState();
    _fetchSalonRating();
  }

  Future<void> openSelectServices(
    BuildContext context,
    String serviceId,
  ) async {
    if (_openingServices[serviceId] == true) return;

    setState(() {
      _openingServices[serviceId] = true;
    });

    try {
      final url = Uri.parse(
        "https://probeauty-backend.onrender.com/api/v1/salons/${widget.salon.id}",
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load salon details")),
        );
        return;
      }

      final json = jsonDecode(response.body);
      final data = json["data"];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectServicesScreen(
            salonId: data["id"],
            salonName: data["name"],
            services: data["services"],
            salonStaffList: data["staff"],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingServices[serviceId] = false;
        });
      }
    }
  }

  Future<void> _fetchSalonRating() async {
    final cached = SalonRatingCache.get(widget.salon.id);

    if (cached != null) {
      setState(() {
        _avgRating = cached.avgRating;
        _totalReviews = cached.totalReviews;
        _loadingRating = false;
      });
      return;
    }

    try {
      final url = Uri.parse(
        "https://probeauty-backend.onrender.com/api/v1/reviews/salon/${widget.salon.id}",
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final rating = SalonRating(
          avgRating: (json["averageRating"] ?? 0).toDouble(),
          totalReviews: json["pagination"]?["total"] ?? 0,
        );

        // ✅ store in cache
        SalonRatingCache.set(widget.salon.id, rating);

        setState(() {
          _avgRating = rating.avgRating;
          _totalReviews = rating.totalReviews;
          _loadingRating = false;
        });
      } else {
        setState(() => _loadingRating = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRating = false);
    }
  }

  List<Widget> _ratingSkeleton() {
    return [
      _skeletonBox(width: 24, height: 14),
      const SizedBox(width: 8),
      _skeletonBox(width: 80, height: 14),
      const SizedBox(width: 8),
      _skeletonBox(width: 28, height: 14),
    ];
  }

  Widget _skeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final salon = widget.salon;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              "assets/images/saloons/saloon1.png",
              width: double.infinity,
              height: width * 0.45,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon.name,
                  style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: _loadingRating
                      ? _ratingSkeleton()
                      : [
                          Text(
                            (_avgRating ?? 0).toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStars(_avgRating ?? 0),
                          const SizedBox(width: 8),
                          Text(
                            "($_totalReviews)",
                            style: const TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 14,
                            ),
                          ),
                        ],
                ),
                const SizedBox(height: 6),
                Text(
                  salon.address ?? "",
                  style: const TextStyle(
                    fontFamily: "PoppinsRegular",
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  children: [
                    for (final s in salon.services) _serviceTile(s),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTile(ServiceModel s) {
    final isLoading = _openingServices[s.id] == true;

    return Column(
      children: [
        Container(
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.softIvory,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: -2,
                offset: Offset(0, 4),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.durationMinutes != null
                          ? "${s.durationMinutes} mins"
                          : "",
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.price != null ? "₹${s.price!.toInt()}" : "",
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              /// ✅ BOOK BUTTON
              GestureDetector(
                onTap:
                    isLoading ? null : () => openSelectServices(context, s.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.softIvory,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.rusticSunset,
                          ),
                        )
                      : const Text(
                          "BOOK",
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int full = rating.floor();
    bool half = rating - full >= 0.5;

    for (int i = 0; i < full; i++) {
      stars
          .add(const Icon(Icons.star, color: AppColors.rusticSunset, size: 20));
    }
    if (half) {
      stars.add(
          const Icon(Icons.star_half, color: AppColors.rusticSunset, size: 20));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border,
          color: AppColors.rusticSunset, size: 20));
    }

    return Row(children: stars);
  }
}
