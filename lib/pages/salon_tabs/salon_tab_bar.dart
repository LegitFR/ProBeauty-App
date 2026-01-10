import "package:flutter/material.dart";
import "package:probeauty_app/l10n/app_localizations.dart";
import "package:probeauty_app/resources/AppColors.dart";

class SalonTabBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int index) onTabTap;

  const SalonTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 45,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabButton(
              title: l10n.salonTabServices,
              index: 0,
              selectedIndex: selectedIndex,
              onTap: () => onTabTap(0),
            ),
            _TabButton(
              title: l10n.salonTabReviews,
              index: 1,
              selectedIndex: selectedIndex,
              onTap: () => onTabTap(1),
            ),
            _TabButton(
              title: l10n.salonTabTeam,
              index: 2,
              selectedIndex: selectedIndex,
              onTap: () => onTabTap(2),
            ),
            _TabButton(
              title: l10n.salonTabDetails,
              index: 3,
              selectedIndex: selectedIndex,
              onTap: () => onTabTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            fontSize: 13,
            color: isActive ? AppColors.rusticSunset : Colors.black54,
          ),
        ),
      ),
    );
  }
}
