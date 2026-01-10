// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewConfirmScreen extends StatefulWidget {
  final String salonId;
  final Map<String, dynamic>? staff;

  final String salonName;
  final DateTime selectedDate;
  final String selectedTime;
  final List<Map<String, dynamic>> selectedServices;
  final bool isFirstVisit;

  const ReviewConfirmScreen({
    super.key,
    required this.salonId,
    required this.staff,
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

  @override
  void initState() {
    super.initState();
    _fetchSalonRating();
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
      final uri = Uri.parse(
        "https://9b81391f2fd7.ngrok-free.app/api/v1/reviews/salon/${widget.salonId}?page=1&limit=1",
      );

      final res = await http.get(uri);

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
    final dt = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      time.hour,
      time.minute,
    );

    return dt.toUtc().toIso8601String();
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
  Future<void> _createBooking({
    required String accessToken,
    required String serviceId,
    required String startTime,
  }) async {
    final uri = Uri.parse(
      "https://probeauty-backend.onrender.com/api/v1/bookings",
    );

    final Map<String, dynamic> body = {
      "salonId": widget.salonId,
      "serviceId": serviceId,
      "startTime": startTime,
    };

    // 🔥 Add staffId ONLY if a specific staff was chosen
    if (widget.staff != null) {
      body["staffId"] = widget.staff!["id"];
    }

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(body),
    );

    final bodyJson = jsonDecode(response.body);

    if (response.statusCode != 201) {
      final message = bodyJson["message"] ?? "Booking failed";
      throw BookingException(message);
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

  Future<void> _initPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "ProBeauty",
        style: ThemeMode.light,
      ),
    );
  }

  Future<void> _presentPaymentSheet(BuildContext context) async {
    await Stripe.instance.presentPaymentSheet();

    // If we reach here → payment SUCCESS
  }

  Future<void> _startStripeCheckout(BuildContext context) async {
    try {
      setState(() => _isProcessing = true);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");

      if (accessToken == null) {
        throw BookingException("User not authenticated");
      }

      final service = widget.selectedServices.first;
      final startTime = _buildStartTimeISO();

      final uri = Uri.parse(
        "https://probeauty-backend.onrender.com/api/v1/bookings/checkout",
      );

      final body = {
        "salonId": widget.salonId,
        "serviceId": service["id"],
        "startTime": startTime,
        if (widget.staff != null) "staffId": widget.staff!["id"],
      };

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(res.body);

      if (res.statusCode != 201) {
        throw BookingException(json["message"] ?? "Checkout failed");
      }

      final clientSecret = json["data"]["clientSecret"];
      final bookingId = json["data"]["booking"]["id"];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "ProBeauty",
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 🔥 SUCCESS → poll & redirect
      await _pollBookingStatus(context, bookingId);
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.error.message ?? "Payment cancelled"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pollBookingStatus(
    BuildContext context,
    String bookingId,
  ) async {
    final uri = Uri.parse(
      "https://probeauty-backend.onrender.com/api/v1/bookings/$bookingId",
    );

    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final status = json["data"]["status"];

        if (status == "CONFIRMED") {
          Navigator.popUntil(context, (route) => route.isFirst);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking confirmed 🎉"),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment received. Booking pending confirmation."),
      ),
    );
  }

  // --------------------------------------------------
  Future<void> _confirmPayAtVenue(BuildContext context) async {
    try {
      setState(() => _isProcessing = true);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");

      if (accessToken == null) {
        throw BookingException("User not authenticated");
      }

      final startTime = _buildStartTimeISO();

      for (final service in widget.selectedServices) {
        await _createBooking(
          accessToken: accessToken,
          serviceId: service["id"],
          startTime: startTime,
        );
      }

      // ✅ SUCCESS → HOME
      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking confirmed 🎉"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --------------------------------------------------
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
    final grandTotal = total + taxes;

    return SafeArea(
      bottom: true,
      child: Scaffold(
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
              onTap: () {
                Navigator.pop(context);
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
                    child: const Center(
                      child: Text("LOGO",
                          style: TextStyle(color: Colors.white, fontSize: 10)),
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
                        const Text("Anna Nagar, Chennai",
                            style: TextStyle(color: Colors.black54)),
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
                  Text(_buildTimeRange()),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(dateText),
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
                              style: const TextStyle(
                                  fontFamily: "PoppinsSemiBold")),
                          Text(
                            l10n.reviewConfirmServiceDuration(
                                s["durationMinutes"]),
                          ),
                        ],
                      ),
                      Text("₹$price",
                          style:
                              const TextStyle(fontFamily: "PoppinsSemiBold")),
                    ],
                  ),
                );
              }),

              const SizedBox(
                height: 15,
              ),
              _priceRow(l10n.reviewConfirmTaxes, taxes),
              // const Divider(),
              _priceRow(l10n.reviewConfirmTotal, grandTotal, bold: true),
              _priceRow(l10n.reviewConfirmPayNow, 0, green: true),
              _priceRow(l10n.reviewConfirmPayAtVenue, grandTotal),

              const SizedBox(height: 15),
              const Divider(thickness: 1),
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
                    payAtVenue = !payAtVenue;
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
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.rusticSunset,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
                      "₹$grandTotal",
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
                          _startStripeCheckout(context);
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
        Text("₹$value",
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
