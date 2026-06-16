// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/models/booking.dart';
import 'package:probeauty_app/pages/appointment_info.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/pages/salon_detail_screen.dart';
import 'package:probeauty_app/providers/appointment_provider.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/salon_service.dart';
import 'package:provider/provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool showAllPrevious = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppointmentProvider>().fetchBookings();
    });
  }

  String formatBookingDate(DateTime dateTime) {
    final dt = dateTime.toLocal();

    const months = [
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

    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    final weekday = weekdays[dt.weekday - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? "pm" : "am";

    return "$weekday, ${dt.day} ${months[dt.month - 1]} "
        "${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
  }

  String _staticMapUrl(double lat, double lng) {
    return "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$lat,$lng"
        "&zoom=15"
        "&size=800x400"
        "&markers=color:red%7C$lat,$lng"
        "&key=YOUR_GOOGLE_MAPS_API_KEY";
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final appointmentProvider = context.watch<AppointmentProvider>();

    final allBookings = appointmentProvider.bookings;
    print(allBookings);

    final sortedBookings = [...allBookings];

    /// SORT LATEST FIRST
    sortedBookings.sort(
      (a, b) => b.startTime.compareTo(a.startTime),
    );

    /// MOST RECENT BOOKING -> UPCOMING SECTION
    final Booking? upcomingBooking =
        sortedBookings.isNotEmpty ? sortedBookings.first : null;

    /// ALL REMAINING BOOKINGS -> PREVIOUS SECTION
    final allPrevious =
        sortedBookings.length > 1 ? sortedBookings.sublist(1) : [];

    final previous =
        showAllPrevious ? allPrevious : allPrevious.take(3).toList();

    /// EMPTY STATE
    final hasUpcoming = upcomingBooking != null;
    final hasPrevious = allPrevious.isNotEmpty;

    if (!hasUpcoming && !hasPrevious) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
      ),
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
            /// ------------ UPCOMING APPOINTMENT CARD ------------

            /// ------------ UPCOMING APPOINTMENT CARD ------------

            if (upcomingBooking != null)
              _buildConfirmedCard(
                upcomingBooking,
                screenWidth,
                screenHeight,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text(
                  "No upcoming appointments",
                  style: TextStyle(
                    fontFamily: "PoppinsMedium",
                  ),
                ),
              ),
            if (previous.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.02),

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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Appointments",
              style: TextStyle(
                fontSize: 32,
                fontFamily: "PlayfairDisplayBold",
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Upcoming",
              style: TextStyle(
                fontSize: 20,
                fontFamily: "PoppinsSemiBold",
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.softIvory,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 236, 136, 93),
                          AppColors.rusticSunset,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No upcoming appointments",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Your upcoming appointments will appear here when you book",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "PoppinsRegular",
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(initialIndex: 1),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Search salons",
                      style: TextStyle(
                          fontFamily: "PoppinsRegular", color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.04),

            // Title
            SkeletonBox(width: w * 0.6, height: 36),

            const SizedBox(height: 30),

            // Confirmed title
            SkeletonBox(width: w * 0.4, height: 22),

            const SizedBox(height: 20),

            // Confirmed card skeleton
            SkeletonBox(
              width: double.infinity,
              height: h * 0.38,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 30),

            // Previous title
            SkeletonBox(width: w * 0.45, height: 22),

            const SizedBox(height: 20),

            // Previous cards
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    SkeletonBox(
                      width: w * 0.22,
                      height: w * 0.22,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: double.infinity, height: 16),
                          SizedBox(height: 8),
                          SkeletonBox(width: 180, height: 14),
                          SizedBox(height: 8),
                          SkeletonBox(width: 140, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();
    // final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: AppColors.softIvory,
        body: SafeArea(
          bottom: true,
          child: appointmentProvider.isLoading
              ? _buildSkeleton(context)
              : _buildContent(context),
        ));
  }

  /// ----------------------------------------------------
  /// CONFIRMED CARD (UI untouched)
  /// ----------------------------------------------------
  Widget _buildConfirmedCard(
    Booking booking,
    double screenWidth,
    double screenHeight,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final salon = booking.salon;
    final services = booking.services;

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    final service = services.first;

    final geo = salon.geo;
    final double? lat = geo?.latitude;
    final double? lng = geo?.longitude;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentInfo(booking: booking),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
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
              child: lat != null && lng != null
                  ? Image.network(
                      _staticMapUrl(lat, lng),
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return child;
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/appointments/map.png",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/appointments/map.png",
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    formatBookingDate(
                      booking.startTime,
                    ),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: "PoppinsSemiBold",
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    l10n.appointmentsDurationPriceService(
                      service.durationMinutes,
                      service.price,
                      service.title,
                    ),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontFamily: "PoppinsRegular",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.navigation_outlined,
                          color: Colors.white,
                        ),
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
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------------------------------------------
  /// PREVIOUS BOOKING CARD (Same UI)
  /// ----------------------------------------------------
  Widget _buildPreviousCard(Booking booking, double screenWidth) {
    final l10n = AppLocalizations.of(context)!;
    final salon = booking.salon;
    final services = booking.services;

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    final String? imageUrl = salon.image;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: screenWidth * 0.22,
                    height: screenWidth * 0.22,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return child;
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/saloons/error.png",
                        width: screenWidth * 0.22,
                        height: screenWidth * 0.22,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/images/saloons/error.png",
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
                  salon.name,
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
                  formatBookingDate(booking.startTime),
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
                  services.map((s) => s.title).join(", "),
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
            onPressed: () async {
              try {
                // Optional loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.rusticSunset,
                    ),
                  ),
                );

                final salonData = await SalonService.fetchSalonById(salon.id);

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalonDetailScreen(
                      id: salonData["id"],
                      name: salonData["name"],
                      address: salonData["address"],
                      image: salonData["thumbnail"] ??
                          "assets/images/saloons/error.png",
                      services: salonData["services"] ?? [],
                      salonStaffList: salonData["staff"] ?? [],
                      hours: salonData["hours"] ?? {},
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to load salon details")),
                );
              }
            },
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
