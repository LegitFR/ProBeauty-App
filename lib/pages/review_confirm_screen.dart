// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/widgets/success_animation.dart';
import 'package:probeauty_app/services/api_client.dart';

class ReviewConfirmScreen extends StatefulWidget {
  final String salonId;
  final Map<String, dynamic>? staff;
  final Map<String, dynamic>? staffMapping;
  final String image;

  final String salonName;
  final DateTime selectedDate;
  final String selectedTime;
  final List<Map<String, dynamic>> selectedServices;
  final bool isFirstVisit;

  const ReviewConfirmScreen({
    super.key,
    required this.salonId,
    required this.staff,
    required this.image,
    required this.staffMapping,
    required this.salonName,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedServices,
    required this.isFirstVisit,
  });

  @override
  State<ReviewConfirmScreen> createState() => _ReviewConfirmScreenState();
}

class _ReviewConfirmScreenState extends State<ReviewConfirmScreen> {
  bool payAtVenue = true;
  bool _isProcessing = false;
  double _avgRating = 0.0;
  int _totalReviews = 0;
  bool _ratingLoading = true;
  static final Map<String, Map<String, dynamic>> _ratingCache = {};
  List<Map<String, dynamic>> _availableOffers = [];
  Map<String, dynamic>? _selectedOffer;
  final TextEditingController _phoneController = TextEditingController();

  bool _offersLoading = true;
  bool _applyingOffer = false;

  @override
  void initState() {
    super.initState();
    _fetchSalonRating();
    _fetchApplicableOffers();
  }

  int _getGrandTotal() {
    final total = widget.selectedServices.fold<int>(
      0,
      (sum, s) => sum + _parsePrice(s["price"]),
    );

    const taxes = 50;
    final discount = (_selectedOffer?["discountAmount"] ?? 0).round();

    final discountedTotal = (total - discount).clamp(0, double.infinity);

    return discountedTotal.toInt() + taxes;
  }

  Map<String, dynamic>? _staffForService(String serviceId) {
    if (widget.staffMapping == null) return widget.staff;
    return widget.staffMapping![serviceId];
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height;

        return SafeArea(
          child: SizedBox(
            height: height * 0.92,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    "Are you sure you want to\nleave this booking",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your booking progress will be lost",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Yes, Exit",
                            style: TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return shouldExit == true;
  }

  Future<void> _showSuccessOverlay() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) {
        return AnimatedSuccessScreen(
          title: "Appointment Booked!",
          buttonText: "Continue booking",
          successSvgPath: "assets/images/icons/success.svg",
          onContinue: () {
            Navigator.pop(context); // close overlay
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _fetchApplicableOffers() async {
    try {
      final res = await ApiClient.get(
        "/api/v1/offers/public/active",
        query: {
          "salonId": widget.salonId,
          "limit": "20",
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body["data"] ?? [];

        final serviceIds = widget.selectedServices.map((s) => s["id"]).toSet();

        _availableOffers = data
            .where((offer) {
              if (offer["offerType"] == "salon") return true;
              if (offer["offerType"] == "service") {
                return serviceIds.contains(offer["serviceId"]);
              }
              return false;
            })
            .cast<Map<String, dynamic>>()
            .toList();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  Future<void> _applyOffer(Map<String, dynamic> offer, int subtotal) async {
    try {
      setState(() => _applyingOffer = true);

      final Map<String, dynamic> payload = {
        "offerId": offer["id"],
        "amount": subtotal.toString(),
      };

      // 🔥 IMPORTANT: build payload based on offerType
      if (offer["offerType"] == "salon") {
        payload["salonId"] = widget.salonId;
      } else if (offer["offerType"] == "service") {
        payload["serviceIds"] =
            widget.selectedServices.map((s) => s["id"]).toList();
      }

      final res = await ApiClient.post(
        "/api/v1/offers/validate",
        body: payload,
      );

      debugPrint("OFFER PAYLOAD => $payload");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json["data"];

        if (data["valid"] == true) {
          setState(() {
            _selectedOffer = {
              ...offer,
              "discountAmount": data["discountAmount"],
            };
          });
        }
      }
    } finally {
      if (mounted) setState(() => _applyingOffer = false);
    }
  }

  void _removeOffer() {
    setState(() {
      _selectedOffer = null;
    });
  }

  Future<void> _fetchSalonRating() async {
    // ✅ 1. Check cache first
    if (_ratingCache.containsKey(widget.salonId)) {
      final cached = _ratingCache[widget.salonId]!;
      setState(() {
        _avgRating = cached["avgRating"];
        _totalReviews = cached["totalReviews"];
        _ratingLoading = false;
      });
      return;
    }

    // ✅ 2. Fetch from API only if not cached
    try {
      final res = await ApiClient.get(
        "/api/v1/reviews/salon/${widget.salonId}",
        query: {
          "page": "1",
          "limit": "1",
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        final avg = (body["averageRating"] ?? 0).toDouble();
        final total = body["pagination"]?["total"] ?? 0;

        // ✅ Save to cache
        _ratingCache[widget.salonId] = {
          "avgRating": avg,
          "totalReviews": total,
        };

        setState(() {
          _avgRating = avg;
          _totalReviews = total;
          _ratingLoading = false;
        });
      } else {
        _ratingFallback();
      }
    } catch (_) {
      _ratingFallback();
    }
  }

  void _ratingFallback() {
    if (!_ratingCache.containsKey(widget.salonId)) {
      setState(() {
        _avgRating = 0.0;
        _totalReviews = 0;
        _ratingLoading = false;
      });
    }
  }

  // --------------------------------------------------
  int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.round();
    if (price is String) {
      return double.tryParse(price)?.round() ?? 0;
    }
    return 0;
  }

  // --------------------------------------------------
  String _buildStartTimeISO() {
    final time = DateFormat("HH:mm").parse(widget.selectedTime);

    // 🚀 Create UTC directly — no conversion
    final dtUtc = DateTime.utc(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      time.hour,
      time.minute,
    );

    return dtUtc.toIso8601String();
  }

  String _buildTimeRange() {
    // Parse start time (local)
    final start = DateFormat("HH:mm").parse(widget.selectedTime);

    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      start.hour,
      start.minute,
    );

    // Sum all service durations
    final totalMinutes = widget.selectedServices.fold<int>(
      0,
      (sum, s) => sum + (s["durationMinutes"] as int? ?? 0),
    );

    final endDateTime = startDateTime.add(Duration(minutes: totalMinutes));

    final startFormatted =
        DateFormat("hh:mm a").format(startDateTime).toLowerCase();
    final endFormatted =
        DateFormat("hh:mm a").format(endDateTime).toLowerCase();

    return "$startFormatted - $endFormatted";
  }

  // --------------------------------------------------
  Future<void> _createBookingMulti() async {
    final startTime = _buildStartTimeISO();

    final serviceIds =
        widget.selectedServices.map((s) => s["id"].toString()).toList();

    // 🔥 map correct staff per service
    final List<String?> staffIds = widget.selectedServices.map((s) {
      final staff = _staffForService(s["id"]);
      return staff?["id"]?.toString(); // can be null = any staff
    }).toList();

    final body = {
      "salonId": widget.salonId,
      "serviceIds": serviceIds,
      "staffIds": staffIds, // always send
      "startTime": startTime,
    };

    print("BODY");
    print(body);

    final response = await ApiClient.post(
      "/api/v1/bookings",
      body: body,
    );

    print(body);

    final json = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw BookingException(json["message"] ?? "Booking failed");
    }
  }

  String _formatTotalDuration() {
    final totalMinutes = widget.selectedServices.fold<int>(
      0,
      (sum, s) => sum + (s["durationMinutes"] as int? ?? 0),
    );

    if (totalMinutes < 60) {
      return "$totalMinutes mins";
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return "$hours hr";
    }

    return "$hours hr $minutes mins";
  }

  Future<void> _confirmPayAtVenue(BuildContext context) async {
    try {
      setState(() => _isProcessing = true);

      await _createBookingMulti();

      await _showSuccessOverlay();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to complete booking. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _pulseOfferLoader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
              color: AppColors.softIvory,
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Finding best offers for you",
                          style: TextStyle(
                              fontSize: 13, fontFamily: "PoppinsSemiBold")),
                      SizedBox(height: 6),
                      Text("Please wait…",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: "PoppinsRegular")),
                    ],
                  ),
                ),
                const Icon(Icons.local_offer, color: AppColors.rusticSunset),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> pollMbWayWebhook({
    required String bookingId,
    required String requestId,
    required dynamic amount,
  }) async {
    try {
      final response = await ApiClient.get(
        "/api/v1/webhooks/ifthenpay/mbway",
        query: {
          "orderId": bookingId,
          "requestId": requestId,
          "amount": amount.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"];
      }
    } catch (e) {
      debugPrint("Webhook polling error: $e");
    }

    return null;
  }

  Future<void> _startMbWayPayment(BuildContext context, int amount) async {
    try {
      setState(() => _isProcessing = true);

      final startTime = _buildStartTimeISO();

      final serviceIds =
          widget.selectedServices.map((s) => s["id"].toString()).toList();

      String? staffId;

// Priority 1: single staff
      if (widget.staff != null && widget.staff!["id"] != null) {
        staffId = widget.staff!["id"].toString();
      }

// Priority 2: from mapping
      else if (widget.staffMapping != null) {
        for (var entry in widget.staffMapping!.values) {
          if (entry != null && entry["id"] != null) {
            staffId = entry["id"].toString();
            break;
          }
        }
      }

      if (staffId == null) {
        throw Exception(
          "Unable to process booking. Please select a staff member.",
        );
      }

      final body = {
        "salonId": widget.salonId,
        "serviceIds": serviceIds,
        "staffId": staffId, // ✅ FIXED
        "startTime": startTime,
        "paymentMethod": "MBWAY",
        "mobileNumber": "351#${_phoneController.text.trim()}",
      };

      final res = await ApiClient.post(
        "/api/v1/bookings/checkout",
        body: body,
      );

      final json = jsonDecode(res.body);

      if (res.statusCode != 201) {
        throw Exception(json["message"] ?? "MBWAY failed");
      }

      final payment = json["data"]["payment"];
      final bookingId = json["data"]["booking"]["id"];

      final requestId = payment["requestId"];
      final amt = payment["amount"];

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            payment["message"] ??
                "Please approve the payment in your MB WAY app.",
          ),
        ),
      );

      // 🔥 POLLING
      int attempts = 0;
      String? status;

      do {
        await Future.delayed(const Duration(seconds: 3));

        status = await pollMbWayWebhook(
          bookingId: bookingId,
          requestId: requestId,
          amount: amt,
        );

        attempts++;
      } while (status != null &&
          status.toUpperCase() == "PAYMENT_PENDING" &&
          attempts < 15);

      if (status != null && (status == "SUCCESS" || status == "000")) {
        await _showSuccessOverlay();
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Payment could not be completed.",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to process payment right now. Please try again.",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final dateText =
        DateFormat("EEEE d MMMM", locale).format(widget.selectedDate);

    final total = widget.selectedServices.fold<int>(
      0,
      (sum, s) => sum + _parsePrice(s["price"]),
    );

    const taxes = 50;
    final discount = (_selectedOffer?["discountAmount"] ?? 0).round();
    final discountedTotal = (total - discount).clamp(0, double.infinity);

    final grandTotal = discountedTotal + taxes;

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          l10n.reviewConfirmTitle,
          style: const TextStyle(
              fontFamily: "PoppinsSemiBold", color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final shouldExit = await _confirmExit();
              if (shouldExit) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.close, color: Colors.black),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SALON HEADER
            Row(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    widget.image, // your logo url variable
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.salonName,
                        style: const TextStyle(
                            fontFamily: "PoppinsSemiBold", fontSize: 15),
                      ),
                      _ratingLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.rusticSunset,
                              ),
                            )
                          : Row(
                              children: [
                                _buildStars(_avgRating),
                                const SizedBox(width: 6),
                                Text(
                                  "($_totalReviews)",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                      // const Text("Anna Nagar, Chennai",
                      //     style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 6),
                Text(_buildTimeRange(),
                    style: TextStyle(
                        fontFamily: "PoppinsRegular", fontSize: 12.5)),
              ],
            ),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  dateText,
                  style:
                      TextStyle(fontFamily: "PoppinsRegular", fontSize: 12.5),
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Divider(thickness: 1),
            const SizedBox(height: 15),

            const Text(
              "Services",
              style: TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            ...widget.selectedServices.map((s) {
              final price = _parsePrice(s["price"]);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s["title"],
                            style:
                                const TextStyle(fontFamily: "PoppinsSemiBold")),
                        Text(
                            l10n.reviewConfirmServiceDuration(
                                s["durationMinutes"]),
                            style: TextStyle(
                                fontFamily: "PoppinsRegular", fontSize: 12.5)),
                      ],
                    ),
                    Text("€$price",
                        style: const TextStyle(fontFamily: "PoppinsSemiBold")),
                  ],
                ),
              );
            }),

            const SizedBox(
              height: 15,
            ),
            _priceRow("Subtotal", total),
            if (_selectedOffer != null)
              _priceRow(
                "Discount",
                -discount,
                green: true,
              ),

            _priceRow("Taxes", taxes),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontFamily: "PoppinsSemiBold"),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_selectedOffer != null)
                      Text(
                        "€${total + taxes}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black45,
                        ),
                      ),
                    Text(
                      "€$grandTotal",
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(thickness: 1),
            const SizedBox(height: 15),

            if (_offersLoading) ...[
              const SizedBox(height: 12),
              const Text(
                "Available offers",
                style: TextStyle(fontFamily: "PoppinsSemiBold", fontSize: 15),
              ),
              const SizedBox(height: 10),
              _pulseOfferLoader(),
            ] else if (_availableOffers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Available offers",
                style: TextStyle(fontFamily: "PoppinsSemiBold", fontSize: 15),
              ),
              const SizedBox(height: 8),
              ..._availableOffers.map((offer) {
                final bool isSelected = _selectedOffer?["id"] == offer["id"];
                final bool disabled = _selectedOffer != null && !isSelected;

                return Opacity(
                  opacity: disabled ? 0.4 : 1,
                  child: GestureDetector(
                    onTap: disabled
                        ? null
                        : () {
                            if (isSelected) {
                              _removeOffer();
                            } else {
                              _applyOffer(offer, total);
                            }
                          },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.rusticSunset
                              : disabled
                                  ? Colors.black12
                                  : Colors.black26,
                        ),
                      ),
                      child: Row(
                        children: [
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
                                : "€${offer["discountValue"]} OFF",
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              color: AppColors.rusticSunset,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 15),

            const Text(
              "Payment method",
              style: TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                setState(() {
                  payAtVenue = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: payAtVenue ? Colors.black : Colors.black26,
                    width: 1.5,
                  ),
                  color: AppColors.softIvory,
                ),
                child: Row(
                  children: [
                    // 🔹 SVG ICON
                    SvgPicture.asset(
                      "assets/images/icons/pay_at_venue.svg",
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "Pay at venue",
                        style: TextStyle(
                          fontFamily: "PoppinsMedium",
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // 🔹 SELECTION INDICATOR
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: payAtVenue
                              ? AppColors.rusticSunset
                              : Colors.black26,
                          width: 1.6,
                        ),
                      ),
                      child: payAtVenue
                          ? const Center(
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: AppColors.rusticSunset,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// ✅ MBWAY OPTION (SEPARATE)
            GestureDetector(
              onTap: () {
                setState(() {
                  payAtVenue = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !payAtVenue ? Colors.black : Colors.black26,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Pay via MBWAY",
                        style: TextStyle(
                          fontFamily: "PoppinsMedium",
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: !payAtVenue ? Colors.black : Colors.black26,
                        ),
                      ),
                      child: !payAtVenue
                          ? const Center(
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: AppColors.rusticSunset,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ PHONE INPUT (ONLY WHEN MBWAY)
            if (!payAtVenue) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintStyle:
                      TextStyle(fontFamily: "PoppinsRegular", fontSize: 13),
                  hintText: "Enter phone number",
                  prefixText: " 351 # ",

                  // 🔥 DEFAULT BORDER
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.rusticSunset),
                  ),

                  // 🔥 WHEN ENABLED (NOT FOCUSED)
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.rusticSunset),
                  ),

                  // 🔥 WHEN FOCUSED (CLICKED)
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.rusticSunset,
                      width: 2, // optional thicker border
                    ),
                  ),

                  // 🔥 ERROR BORDER (optional but clean)
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              )
            ],

            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "€$grandTotal",
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${widget.selectedServices.length} "
                      "${widget.selectedServices.length > 1 ? "services" : "service"} • "
                      "${_formatTotalDuration()}",
                      style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () {
                        if (payAtVenue) {
                          _confirmPayAtVenue(context);
                        } else {
                          // MBWAY
                          if (_phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter phone number.")),
                            );
                            return;
                          }

                          _startMbWayPayment(context, _getGrandTotal());
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rusticSunset,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isProcessing
                    ? const LoadingDots() // 🔥 YOUR ANIMATION
                    : Text(
                        l10n.reviewConfirmConfirmButton,
                        style: const TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (rating >= i + 1) {
          return const Icon(Icons.star,
              size: 15, color: AppColors.rusticSunset);
        } else if (rating > i) {
          return const Icon(Icons.star_half,
              size: 15, color: AppColors.rusticSunset);
        } else {
          return const Icon(Icons.star_border,
              size: 15, color: AppColors.rusticSunset);
        }
      }),
    );
  }

  Widget _priceRow(String label, int value,
      {bool bold = false, bool green = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: bold ? "PoppinsSemiBold" : "PoppinsRegular",
                color: green ? Colors.green : Colors.black)),
        Text("€$value",
            style: TextStyle(
                fontFamily: bold ? "PoppinsSemiBold" : "PoppinsRegular",
                color: green ? Colors.green : Colors.black)),
      ],
    );
  }
}

class BookingException implements Exception {
  final String message;
  BookingException(this.message);

  @override
  String toString() => message;
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double delay = index * 0.2;
        final double value = (_controller.value + delay) % 1.0;

        final double opacity = (1 - (value - 0.5).abs() * 2).clamp(0.3, 1.0);

        final double translateY =
            -6 * (1 - (value - 0.5).abs() * 2).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(0),
        const SizedBox(width: 8),
        _dot(1),
        const SizedBox(width: 8),
        _dot(2),
      ],
    );
  }
}
