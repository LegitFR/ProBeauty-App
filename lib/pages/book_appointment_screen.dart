import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/first_visit_screen.dart';
import 'package:probeauty_app/pages/home_screen.dart';
import 'package:probeauty_app/pages/main_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';
import 'package:probeauty_app/services/api_client.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String image;
  final Map<String, dynamic>? staff; // keep for compatibility
  final Map<String, dynamic>? staffMapping; // 🔥 ADD

  final List<Map<String, dynamic>> selectedServices;

  const BookAppointmentScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.image,
    required this.staff,
    required this.staffMapping,
    required this.selectedServices,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  int? selectedSlotIndex;

  bool loadingSlots = false;
  List<dynamic> slots = [];

  Map<String, dynamic> get service => widget.selectedServices.first;

  @override
  void initState() {
    super.initState();
    _fetchSlotsForDate(selectedDate);
  }

  Map<String, dynamic>? _staffForService(String serviceId) {
    if (widget.staffMapping == null) return widget.staff;
    return widget.staffMapping![serviceId];
  }

  Future<bool> _confirmExit() async {
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
            height: height * 0.92,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            "Yes, Exit",
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

    return shouldExit == true;
  }

  // --------------------------------------------------
  // WEEKDAY KEY
  // --------------------------------------------------
  String _weekdayKey(DateTime date) {
    return [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ][date.weekday - 1];
  }

  // --------------------------------------------------
  // STAFF WORKING DAY CHECK
  // --------------------------------------------------
  bool _isStaffAvailableOn(DateTime date) {
    // 🔥 If Any staff selected → allow all days
    if (widget.staff == null) return true;

    final dayKey = _weekdayKey(date);
    final availability = widget.staff!["availability"]?[dayKey];
    return availability != null && availability["isAvailable"] == true;
  }

  // --------------------------------------------------
  // FETCH SLOTS FROM BACKEND
  // --------------------------------------------------
  Future<void> _fetchSlotsForDate(DateTime date) async {
    // ❌ Staff not available → no slots
    if (!_isStaffAvailableOn(date)) {
      if (!mounted) return;
      setState(() {
        slots = [];
        selectedSlotIndex = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      loadingSlots = true;
      slots = [];
      selectedSlotIndex = null;
    });

    final dateStr = DateFormat("yyyy-MM-dd").format(date);

    try {
      final response = await ApiClient.get(
        "/api/v1/bookings/availability",
        query: {
          "salonId": widget.salonId,
          "serviceId": service["id"].toString(),
          if (widget.staff != null) "staffId": widget.staff!["id"].toString(),
          "date": dateStr,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List rawSlots = body["data"]["slots"] ?? [];

        final now = DateTime.now();
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        // 🔥 FILTER PAST SLOTS ONLY FOR TODAY
        final filteredSlots = isToday
            ? rawSlots.where((slot) {
                final slotUtc = DateTime.parse(slot["startTime"]).toUtc();
                return slotUtc.isAfter(DateTime.now().toUtc());
              }).toList()
            : rawSlots;

        setState(() {
          slots = filteredSlots;
          loadingSlots = false;
        });
      } else {
        setState(() => loadingSlots = false);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() => loadingSlots = false);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to load available slots. Please try again.",
          ),
        ),
      );
    }
  }

  String displayTime(String iso) {
    final utc = DateTime.parse(iso).toUtc();
    return DateFormat("hh:mm a").format(utc).toLowerCase();
  }

  Widget _buildQuickDates() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    Widget button(String title, DateTime date) {
      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              currentMonth = DateTime(date.year, date.month);
            });

            _fetchSlotsForDate(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26),
              color: isSelected ? AppColors.rusticSunset : AppColors.softIvory,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "PoppinsSemiBold",
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat("d MMM yyyy").format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          button("Today", today),
          button("Tomorrow", tomorrow),
        ],
      ),
    );
  }

  Widget _buildSelectedServicesCard() {
    if (widget.selectedServices.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ListView.separated(
            itemCount: widget.selectedServices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final service = widget.selectedServices[index];
              final staff = _staffForService(service["id"]);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service["title"] ?? "Service",
                            style: const TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 🔥 correct staff per service
                          Text(
                            staff?["name"] ?? "Any staff",
                            style: const TextStyle(
                              fontFamily: "PoppinsRegular",
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "€${service["price"] ?? "--"}",
                      style: const TextStyle(
                        fontFamily: "PoppinsSemiBold",
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            onTap: () {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add,
                    color: AppColors.rusticSunset,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Add another service",
                    style: TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 14,
                      color: AppColors.rusticSunset,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CALENDAR (UNCHANGED UI, LOGIC EXTENDED)
  // --------------------------------------------------
  Widget _buildCalendar() {
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now(); // 🔥 ADD THIS

    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    List<Widget> tiles = [];

    // Empty tiles before first weekday
    for (int i = 1; i < firstDay.weekday; i++) {
      tiles.add(const SizedBox());
    }

    for (int d = 1; d <= lastDay.day; d++) {
      final date = DateTime(currentMonth.year, currentMonth.month, d);

      // 🔥 FIXED past check
      final isPast = date.isBefore(
        DateTime(now.year, now.month, now.day),
      );

      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      final isWorkingDay = _isStaffAvailableOn(date);

      tiles.add(
        GestureDetector(
          onTap: (isPast || !isWorkingDay)
              ? null
              : () {
                  setState(() {
                    selectedDate = date;

                    // 🔥 ensures month header updates correctly
                    currentMonth = DateTime(date.year, date.month);
                  });

                  _fetchSlotsForDate(date);
                },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.rusticSunset : null,
            ),
            child: Center(
              child: Text(
                "$d",
                style: TextStyle(
                  fontFamily: "PoppinsSemiBold",
                  color: isSelected
                      ? Colors.white
                      : (isPast || !isWorkingDay)
                          ? Colors.grey
                          : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekDay(l10n.bookAppointmentWeekMon),
              _WeekDay(l10n.bookAppointmentWeekTue),
              _WeekDay(l10n.bookAppointmentWeekWed),
              _WeekDay(l10n.bookAppointmentWeekThu),
              _WeekDay(l10n.bookAppointmentWeekFri),
              _WeekDay(l10n.bookAppointmentWeekSat),
              _WeekDay(l10n.bookAppointmentWeekSun),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tiles,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        backgroundColor: AppColors.softIvory,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.bookAppointmentTitle,
          style: const TextStyle(fontFamily: "PoppinsSemiBold"),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final shouldExit = await _confirmExit();
              if (shouldExit) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MainScreen(initialIndex: 0), // 👈 HOME TAB
                  ),
                  (route) => false,
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.close, color: Colors.black),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQuickDates(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentMonth.month == DateTime.now().month &&
                            currentMonth.year == DateTime.now().year
                        ? null
                        : () {
                            setState(() {
                              currentMonth = DateTime(
                                  currentMonth.year, currentMonth.month - 1);
                            });
                          },
                  ),
                  Text(
                    DateFormat("MMMM yyyy", locale).format(currentMonth),
                    style: const TextStyle(
                      fontFamily: "PoppinsSemiBold",
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        currentMonth =
                            DateTime(currentMonth.year, currentMonth.month + 1);
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildCalendar(),
            const Divider(),
            if (loadingSlots)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: AppColors.rusticSunset,
                ),
              )
            else if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "No slots available for the selected date",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "PoppinsMedium",
                    color: Colors.black54,
                  ),
                ),
              )
            else
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: slots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final slot = slots[i];
                    final isAvailable = slot["available"] == true;
                    final isSelected = selectedSlotIndex == i;

                    return GestureDetector(
                      onTap: !isAvailable
                          ? null
                          : () {
                              if (selectedSlotIndex == i) return;
                              setState(() {
                                selectedSlotIndex = i;
                              });

                              final startTime =
                                  DateTime.parse(slot["startTime"]); // UTC 그대로

                              final formattedTime =
                                  DateFormat("HH:mm").format(startTime);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FirstVisitScreen(
                                    salonId: widget.salonId,
                                    salonName: widget.salonName,
                                    image: widget.image,
                                    staff: widget.staffMapping,
                                    date: selectedDate,
                                    time: formattedTime,
                                    staffMapping: widget.staffMapping,
                                    selectedServices: widget.selectedServices,
                                  ),
                                ),
                              );
                            },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isAvailable ? Colors.black : Colors.black26,
                          ),
                          color: !isAvailable
                              ? Colors.grey.shade400
                              : isSelected
                                  ? AppColors.rusticSunset
                                  : AppColors.softIvory,
                        ),
                        child: Text(
                          displayTime(slot["startTime"]),
                          style: TextStyle(
                            fontFamily: "PoppinsSemiBold",
                            color: !isAvailable
                                ? Colors.black45
                                : isSelected
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            _buildSelectedServicesCard(),
          ],
        ),
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String label;
  const _WeekDay(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontFamily: "PoppinsRegular"));
  }
}
