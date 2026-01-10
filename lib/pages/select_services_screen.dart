import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/select_professional_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SelectServicesScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final List<dynamic> services;
  final List<dynamic> salonStaffList;

  const SelectServicesScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.services,
    required this.salonStaffList,
  });

  @override
  State<SelectServicesScreen> createState() => _SelectServicesScreenState();
}

class _SelectServicesScreenState extends State<SelectServicesScreen> {
  late List<String> categories;
  late String selectedCategory;

  List<Map<String, dynamic>> selectedServices = [];

  @override
  void initState() {
    super.initState();

    categories = widget.services
        .map((s) => (s["category"] ?? "Featured").toString())
        .toSet()
        .toList();

    categories.sort((a, b) => a == "Featured" ? -1 : 1);
    selectedCategory = categories.first;
  }

  Future<bool> _onBackPressed() async {
    if (selectedServices.isEmpty) {
      Navigator.pop(context);
      return false;
    }

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
            height: height * 0.92, // 🔥 slightly smaller than full screen
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔘 DRAG HANDLE (NOTCH)
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

                  // ---- TITLE ----
                  const Text(
                    "Are you sure you want to\nleave this booking",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "All selections will be lost",
                    style: TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const Spacer(),

                  // ---- BUTTONS ----
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
                            "yes, exit",
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

    if (shouldExit == true) {
      Navigator.pop(context); // ✅ exit page
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = widget.services
        .where(
            (s) => (s["category"] ?? "Featured").toString() == selectedCategory)
        .toList();

    return SafeArea(
      bottom: true,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: AppColors.softIvory,
          appBar: AppBar(
            backgroundColor: AppColors.softIvory,
            elevation: 0,
            leading: GestureDetector(
              onTap: _onBackPressed,
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
            centerTitle: true,
            title: Text(
              l10n.selectServicesTitle,
              style: const TextStyle(
                fontFamily: "PoppinsSemiBold",
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isActive = selectedCategory == cat;

                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 14,
                              color: isActive
                                  ? AppColors.softIvory
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _serviceTile(filtered[index]);
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: ElevatedButton(
              onPressed: selectedServices.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SelectProfessionalScreen(
                                  salonId: widget.salonId,
                                  salonName: widget.salonName,
                                  staffList: widget.salonStaffList,
                                  selectedServices: selectedServices,
                                )),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rusticSunset,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n.selectServicesContinue,
                style: const TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceTile(Map<String, dynamic> service) {
    final l10n = AppLocalizations.of(context)!;
    final serviceId = service["id"];
    final isSelected = selectedServices.any((s) => s["id"] == serviceId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedServices.removeWhere((s) => s["id"] == serviceId);
          } else {
            selectedServices.add(service);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.softIvory,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service["title"],
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    l10n.selectServicesDuration(service["durationMinutes"]),
                    style: const TextStyle(
                      fontFamily: "PoppinsRegular",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${service["price"]}",
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.rusticSunset : Colors.black12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                color: isSelected ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
