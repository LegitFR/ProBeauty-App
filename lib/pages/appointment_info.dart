import "package:flutter/material.dart";
import "package:probeauty_app/resources/AppColors.dart";
import "package:probeauty_app/models/booking.dart";

class AppointmentInfo extends StatelessWidget {
  final Booking booking;

  const AppointmentInfo({
    super.key,
    required this.booking,
  });

  String _formatDateTime(DateTime dt) {
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

    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? "pm" : "am";

    return "${dt.day} ${months[dt.month - 1]} ${dt.year} at "
        "$hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final salon = booking.salon;
    final service = booking.service;
    final staff = booking.staff;

    final duration = service.durationMinutes;
    final price = double.tryParse(service.price) ?? 0;
    final tax = price * 0.07; // example 7%
    final total = price + tax;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: AppBar(
          backgroundColor: AppColors.softIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            salon.name,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: "PoppinsSemiBold",
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Salon Image =====
              Stack(
                children: [
                  Image.network(
                    salon.image ?? "https://via.placeholder.com/600x400",
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/appointments/saloon_thumb_1.png",
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // ===== Status Badge =====
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: booking.status == "CONFIRMED"
                            ? AppColors.rusticSunset
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            booking.status == "CONFIRMED"
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            booking.status,
                            style: const TextStyle(
                              fontFamily: "PoppinsMedium",
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // ===== Date & Time =====
                    Text(
                      _formatDateTime(booking.startTime),
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontFamily: "PoppinsSemiBold",
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$duration minutes"
                      "${staff != null ? " • With ${staff.name}" : ""}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontFamily: "PoppinsRegular",
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // ===== Overview =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontFamily: "PoppinsSemiBold",
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ===== Service =====
              _priceTile(
                title: service.title,
                subtitle: "$duration minutes",
                amount: price,
              ),

              _priceTile(
                title: "Taxes",
                amount: tax,
              ),

              _priceTile(
                title: "Total",
                amount: total,
                isTotal: true,
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceTile({
    required String title,
    String? subtitle,
    required double amount,
    bool isTotal = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.softIvory,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: isTotal ? 16 : 14,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: "PoppinsRegular",
                  color: Colors.black54,
                ),
              ),
          ]),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
