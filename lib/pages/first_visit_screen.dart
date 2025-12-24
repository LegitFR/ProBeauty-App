import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/review_confirm_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class FirstVisitScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final Map<String, dynamic> staff;
  final double rating;
  final DateTime date;
  final String time;
  final List<Map<String, dynamic>> selectedServices;

  const FirstVisitScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.staff,
    required this.rating,
    required this.date,
    required this.time,
    required this.selectedServices,
  });

  void _goNext(BuildContext context, bool isFirstVisit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewConfirmScreen(
          salonId: salonId,
          salonName: salonName,
          staff: staff,
          rating: rating,
          reviewCount: 1240,
          selectedDate: date,
          selectedTime: time,
          selectedServices: selectedServices,
          isFirstVisit: isFirstVisit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,
        appBar: AppBar(
          backgroundColor: AppColors.softIvory,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ---------- TITLE ----------
              Text(
                l10n.firstVisitTitle(salonName),
                style: const TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  fontSize: 22,
                  height: 1.3,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // ---------- YES ----------
              _optionCard(
                title: l10n.firstVisitYesTitle,
                subtitle: l10n.firstVisitYesSubtitle,
                onTap: () => _goNext(context, true),
              ),

              const SizedBox(height: 14),

              // ---------- NO ----------
              _optionCard(
                title: l10n.firstVisitNoTitle,
                subtitle: l10n.firstVisitNoSubtitle,
                onTap: () => _goNext(context, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // OPTION CARD UI
  // ------------------------------
  Widget _optionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
          color: AppColors.softIvory,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: "PoppinsRegular",
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
