import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class TeamScreen extends StatelessWidget {
  final String salonName;
  final List<dynamic> staffList;

  const TeamScreen({
    super.key,
    required this.salonName,
    required this.staffList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.softIvory,

        // ---------------- APP BAR ----------------
        appBar: AppBar(
          backgroundColor: AppColors.softIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            salonName,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),

        // ---------------- BODY ----------------
        body: Column(
          children: [
            // ---------------- TOP TAB BAR ----------------
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
                        Navigator.pop(context); // back to services
                      },
                      child: _TopTab(
                        title: l10n.reviewsTabServices,
                        isActive: false,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // back to reviews screen
                      },
                      child: _TopTab(
                        title: l10n.reviewsTabReviews,
                        isActive: false,
                      ),
                    ),
                    _TopTab(
                      title: l10n.reviewsTabTeam,
                      isActive: true, // 👈 ACTIVE TAB
                    ),
                    _TopTab(
                      title: l10n.reviewsTabDetails,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- TEAM GRID ----------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: staffList.length, // +1 for Any Staff
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    // 🔵 STAFF CARD
                    final staff = staffList[index];
                    return _professionalCard(staff, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STAFF CARD ----------------
  Widget _professionalCard(Map<String, dynamic> staff, BuildContext context) {
    final String? imageUrl = staff["image"]; // 👈 adjust key if needed

    return Container(
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // -------- AVATAR / IMAGE --------
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.black)
                : null,
          ),

          const SizedBox(height: 12),

          // -------- NAME --------
          Text(
            staff["name"] ??
                AppLocalizations.of(context)!.selectProfessionalFallbackName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- TOP TAB WIDGET ----------------
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
