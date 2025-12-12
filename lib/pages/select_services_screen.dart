import 'package:flutter/material.dart';
import 'package:probeauty_app/pages/select_professional_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class SelectServicesScreen extends StatefulWidget {
  final String salonName;
  final List<dynamic> services;
  final List<dynamic> salonStaffList;

  const SelectServicesScreen({
    super.key,
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

  /// ✅ STORE FULL SERVICE OBJECTS
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

  @override
  Widget build(BuildContext context) {
    final filtered = widget.services
        .where(
            (s) => (s["category"] ?? "Featured").toString() == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          "Select Services",
          style: TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
          ),
        ),
      ),

      // BODY
      body: Column(
        children: [
          // ----------- CATEGORY TABS -----------
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 14,
                        color: isActive ? AppColors.softIvory : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(thickness: 1),

          // ----------- SERVICE LIST -----------
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

      // ----------- CONTINUE BUTTON -----------
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
                        staffList: widget.salonStaffList,
                        selectedServices: selectedServices,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rusticSunset,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            "Continue",
            style: TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 14,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // SERVICE TILE — USE ID FOR SELECTION CHECK (IMPORTANT!)
  // -----------------------------------------------------------
  Widget _serviceTile(Map<String, dynamic> service) {
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
            // LEFT SIDE TEXT
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
                    "${service["durationMinutes"]} mins",
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

            // RIGHT SIDE INDICATOR
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
