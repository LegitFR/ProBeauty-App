// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewConfirmScreen extends StatelessWidget {
  final String salonId;
  final Map<String, dynamic>? staff;

  final String salonName;
  final double rating;
  final int reviewCount;
  final DateTime selectedDate;
  final String selectedTime;
  final List<Map<String, dynamic>> selectedServices;
  final bool isFirstVisit;

  const ReviewConfirmScreen({
    super.key,
    required this.salonId,
    required this.staff,
    required this.salonName,
    required this.rating,
    required this.reviewCount,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedServices,
    required this.isFirstVisit,
  });

  // --------------------------------------------------
  // PRICE PARSER (FIXES ₹0 ISSUE)
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
  // BUILD START TIME (ISO)
  // --------------------------------------------------
  String _buildStartTimeISO() {
    final time = DateFormat("HH:mm").parse(selectedTime);
    final dt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );

    return dt.toUtc().toIso8601String();
  }

  // --------------------------------------------------
  // CREATE BOOKING (ONE SERVICE)
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
      "salonId": salonId,
      "serviceId": serviceId,
      "startTime": startTime,
    };

    // 🔥 Add staffId ONLY if a specific staff was chosen
    if (staff != null) {
      body["staffId"] = staff!["id"];
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

  // --------------------------------------------------
  // CONFIRM ALL BOOKINGS
  // --------------------------------------------------
  Future<void> _confirmBookings(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");

      if (accessToken == null) {
        throw BookingException("User not authenticated");
      }

      final startTime = _buildStartTimeISO();

      for (final service in selectedServices) {
        await _createBooking(
          accessToken: accessToken,
          serviceId: service["id"],
          startTime: startTime,
        );
      }

      // ✅ SUCCESS
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.reviewConfirmBookingSuccess),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } on BookingException catch (e) {
      // ❌ BUSINESS ERROR (like staff not available)
      final msg = e.message.contains("not available")
          ? AppLocalizations.of(context)!.reviewConfirmStaffUnavailable
          : e.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      // ❌ UNKNOWN ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.reviewConfirmGenericError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final dateText = DateFormat("EEEE d MMMM", locale).format(selectedDate);
    final timeText =
        DateFormat("hh:mm a").format(DateFormat("HH:mm").parse(selectedTime));

    final total = selectedServices.fold<int>(
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
                          salonName,
                          style: const TextStyle(
                              fontFamily: "PoppinsSemiBold", fontSize: 15),
                        ),
                        Row(
                          children: [
                            _buildStars(rating),
                            const SizedBox(width: 6),
                            Text("($reviewCount)",
                                style: const TextStyle(fontSize: 12)),
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
                  Text("$timeText - 12:45 pm"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(dateText),
                ],
              ),

              const SizedBox(height: 16),

              ...selectedServices.map((s) {
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

              const Divider(),
              _priceRow(l10n.reviewConfirmTaxes, taxes),
              const Divider(),
              _priceRow(l10n.reviewConfirmTotal, grandTotal, bold: true),
              _priceRow(l10n.reviewConfirmPayNow, 0, green: true),
              _priceRow(l10n.reviewConfirmPayAtVenue, grandTotal),

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
                child: Text(
                  l10n.reviewConfirmBottomSummary(
                      "₹", grandTotal, selectedServices.length),
                  style: const TextStyle(
                      fontFamily: "PoppinsSemiBold", fontSize: 13),
                ),
              ),
              ElevatedButton(
                onPressed: () => _confirmBookings(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rusticSunset,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  l10n.reviewConfirmConfirmButton,
                  style: const TextStyle(
                      fontFamily: "PoppinsSemiBold", color: Colors.white),
                ),
              )
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
