import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/book_appointment_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';

class SelectProfessionalScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String image;

  final List<dynamic> staffList;
  final List<Map<String, dynamic>> selectedServices;

  const SelectProfessionalScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.image,
    required this.staffList,
    required this.selectedServices,
  });

  @override
  State<SelectProfessionalScreen> createState() =>
      _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  int selectedServiceIndex = 0;

  /// serviceId -> selected staff
  final Map<String, dynamic> selectedStaffPerService = {};

  /// currently visible staffs
  List<dynamic> currentStaffList = [];

  /// loading state
  bool isLoadingStaff = false;

  /// cache per service
  final Map<String, List<dynamic>> serviceStaffCache = {};

  Map<String, dynamic> get currentService =>
      widget.selectedServices[selectedServiceIndex];

  @override
  void initState() {
    super.initState();

    fetchStaffForService(currentService["id"]);
  }

  Future<void> fetchStaffForService(String serviceId) async {
    // ✅ use cache if already fetched
    if (serviceStaffCache.containsKey(serviceId)) {
      setState(() {
        currentStaffList = serviceStaffCache[serviceId]!;
      });
      return;
    }

    setState(() {
      isLoadingStaff = true;
    });

    try {
      final response = await ApiClient.get(
        "/api/v1/staff/salon/${widget.salonId}",
        query: {
          "serviceId": serviceId,
          "limit": "20",
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> staffs = decoded["data"] ?? [];

        // ✅ only remove invalid names
        final filtered = staffs.where((staff) {
          final name = (staff["name"] ?? "").toString().trim().toUpperCase();

          return name != "UNKNOWN" && name.isEmpty == false;
        }).toList();

        // ✅ cache service staffs
        serviceStaffCache[serviceId] = filtered;

        setState(() {
          currentStaffList = filtered;
        });
      } else {
        setState(() {
          currentStaffList = [];
        });
      }
    } catch (e) {
      setState(() {
        currentStaffList = [];
      });
    }

    setState(() {
      isLoadingStaff = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        title: Text(
          l10n.selectProfessionalTitle,
          style: const TextStyle(
            fontFamily: "PoppinsSemiBold",
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ---------------- SERVICE SELECTOR ----------------
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.selectedServices.length,
              itemBuilder: (context, index) {
                final service = widget.selectedServices[index];
                final isSelected = index == selectedServiceIndex;

                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedServiceIndex = index;
                    });

                    await fetchStaffForService(
                      widget.selectedServices[index]["id"],
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.rusticSunset
                          : AppColors.softIvory,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        service["title"],
                        style: TextStyle(
                          fontFamily: "PoppinsSemiBold",
                          fontSize: 13,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- STAFF GRID ----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoadingStaff
                  ? GridView.builder(
                      itemCount: 4,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (_, __) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      itemCount: currentStaffList.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final serviceId = currentService["id"];

                        // 🟢 ANY STAFF
                        if (index == 0) {
                          final isSelected =
                              selectedStaffPerService[serviceId] == null &&
                                  selectedStaffPerService
                                      .containsKey(serviceId);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStaffPerService[serviceId] = null;
                              });
                            },
                            child: _anyStaffCard(isSelected),
                          );
                        }
                        if (currentStaffList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 32,
                                  color: Colors.black45,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No specific staff available",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "PoppinsMedium",
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final staff = currentStaffList[index - 1];

                        final isSelected = selectedStaffPerService[serviceId]
                                ?["id"] ==
                            staff["id"];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStaffPerService[serviceId] = staff;
                            });
                          },
                          child: _professionalCard(
                            staff,
                            isSelected,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookAppointmentScreen(
                    salonId: widget.salonId,
                    salonName: widget.salonName,
                    image: widget.image,
                    staff: null,
                    selectedServices: widget.selectedServices,
                    staffMapping: selectedStaffPerService,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rusticSunset,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.selectServicesContinue,
              style: const TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ANY STAFF CARD ----------------
  Widget _anyStaffCard(bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.rusticSunset.withOpacity(0.15)
            : AppColors.rusticSunset.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.rusticSunset : Colors.black26,
          width: 2.5,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_2_outlined,
              size: 34, color: AppColors.rusticSunset),
          SizedBox(height: 12),
          Text(
            "Any Staff",
            style: TextStyle(
              fontFamily: "PoppinsSemiBold",
              fontSize: 15,
              color: AppColors.rusticSunset,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STAFF CARD ----------------
  Widget _professionalCard(Map<String, dynamic> staff, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.rusticSunset.withOpacity(0.15)
            : AppColors.softIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.rusticSunset : Colors.black,
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 30),
          const SizedBox(height: 12),
          Text(
            staff["name"] ?? "Staff",
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
