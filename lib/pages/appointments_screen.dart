import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final String baseUrl =
      "https://probeauty-backend.onrender.com/api/v1/bookings";

  bool loading = true;
  List<dynamic> allBookings = [];
  bool showAllPrevious = false;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (!mounted) return; // 🔐 critical

      if (token == null) {
        setState(() => loading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (!mounted) return; // 🔐 critical

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List bookings = data["data"] ?? [];

        bookings.sort((a, b) {
          return DateTime.parse(b["startTime"])
              .compareTo(DateTime.parse(a["startTime"]));
        });

        setState(() {
          allBookings = bookings;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      if (!mounted) return; // 🔐 critical
      setState(() => loading = false);
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso).toLocal();

    final months = [
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

    String weekday =
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dt.weekday - 1];
    String ampm = dt.hour >= 12 ? "pm" : "am";
    int hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;

    return "$weekday, ${dt.day} ${months[dt.month - 1]} ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.softIvory,
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.rusticSunset,
        )),
      );
    }

    // fallback when no bookings exist
    if (allBookings.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.softIvory,
        body: Center(
          child: Text(
            l10n.appointmentsEmpty,
            style: const TextStyle(fontSize: 18, fontFamily: "PoppinsMedium"),
          ),
        ),
      );
    }

    // FIRST booking → Confirmed
    final confirmed = allBookings.isNotEmpty ? allBookings.first : null;

    // Remaining → Previous
    final allPrevious = allBookings.length > 1 ? allBookings.sublist(1) : [];

    final previous =
        showAllPrevious ? allPrevious : allPrevious.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.04),

                /// ------------ TITLE ------------
                Text(
                  l10n.appointmentsTitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontFamily: "PlayfairDisplayBold",
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                /// ------------ CONFIRMED SECTION TITLE ------------
                Text(
                  l10n.appointmentsConfirmedTitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: "PoppinsSemiBold",
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                /// ------------ CONFIRMED APPOINTMENT CARD ------------
                if (confirmed != null)
                  _buildConfirmedCard(confirmed, screenWidth, screenHeight),

                SizedBox(height: screenHeight * 0.02),

                /// ------------ PREVIOUS SECTION TITLE ------------
                /// ------------ PREVIOUS SECTION HEADER ------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.appointmentsPreviousTitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontFamily: "PoppinsSemiBold",
                        color: Colors.black87,
                      ),
                    ),

                    // 👇 SEE ALL / SHOW LESS
                    if (allPrevious.length > 3)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllPrevious = !showAllPrevious;
                          });
                        },
                        child: Text(
                          showAllPrevious
                              ? l10n.appointmentsShowLess
                              : l10n.appointmentsSeeAll,
                          style: const TextStyle(
                            fontFamily: "PoppinsMedium",
                            fontSize: 14,
                            color: AppColors.rusticSunset,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ------------ PREVIOUS BOOKINGS LIST ------------
                Column(
                  children: previous.map((booking) {
                    return _buildPreviousCard(booking, screenWidth);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ----------------------------------------------------
  /// CONFIRMED CARD (UI untouched)
  /// ----------------------------------------------------
  Widget _buildConfirmedCard(
      dynamic b, double screenWidth, double screenHeight) {
    final l10n = AppLocalizations.of(context)!;
    final salon = b["salon"];
    final service = b["service"];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              "assets/images/appointments/map.png",
              width: double.infinity,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/appointment_info');
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon?["name"] ?? l10n.appointmentsUnknownSalon,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    _formatDate(b["startTime"]),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    l10n.appointmentsDurationPriceService(
                        service?["durationMinutes"] ?? 60,
                        service?["price"] ?? "0",
                        service?["title"] ?? ""),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: "PoppinsRegular",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.navigation_outlined,
                            color: Colors.white),
                        label: Text(
                          l10n.appointmentsGetDirections,
                          style: TextStyle(
                            fontFamily: "PoppinsRegular",
                            fontSize: screenHeight * 0.013,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rusticSunset,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.lighterGreyTone,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.calendar_month_sharp,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ----------------------------------------------------
  /// PREVIOUS BOOKING CARD (Same UI)
  /// ----------------------------------------------------
  Widget _buildPreviousCard(dynamic b, double screenWidth) {
    final l10n = AppLocalizations.of(context)!;
    final salon = b["salon"];
    final service = b["service"];

    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail fixed static image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/appointments/saloon_thumb_1.png",
              width: screenWidth * 0.22,
              height: screenWidth * 0.22,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon?["name"] ?? l10n.appointmentsUnknownSalon,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontFamily: "PoppinsBold",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(b["startTime"]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontFamily: "PoppinsMedium",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appointmentsDurationPriceService(
                      service?["durationMinutes"] ?? 60,
                      service?["price"] ?? "0",
                      service?["title"] ?? ""),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontFamily: "PoppinsRegular",
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Text(
              l10n.appointmentsBookAgain,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontFamily: "PoppinsRegular",
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
