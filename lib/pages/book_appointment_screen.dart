import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:probeauty_app/l10n/app_localizations.dart';
import 'package:probeauty_app/pages/first_visit_screen.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final Map<String, dynamic>? staff;
  final List<Map<String, dynamic>> selectedServices;

  const BookAppointmentScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.staff,
    required this.selectedServices,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
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

    final uri = Uri.parse(
      "https://probeauty-backend.onrender.com/api/v1/bookings/availability"
      "?salonId=${widget.salonId}"
      "&serviceId=${service["id"]}"
      "${widget.staff != null ? "&staffId=${widget.staff!["id"]}" : ""}"
      "&date=$dateStr",
    );

    try {
      final res = await http.get(uri);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List rawSlots = body["data"]["slots"] ?? [];

        final now = DateTime.now();

        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        // 🔥 FILTER PAST SLOTS ONLY FOR TODAY
        final filteredSlots = isToday
            ? rawSlots.where((slot) {
                final slotLocal = _utcToLocal(slot["startTime"]);
                return slotLocal.isAfter(DateTime.now());
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
    }
  }

  DateTime _utcToLocal(String iso) {
    return DateTime.parse(iso).toLocal();
  }

  String displayTime(String iso) {
    final local = DateTime.parse(iso).toLocal();
    return DateFormat("hh:mm a").format(local).toLowerCase();
  }

  // --------------------------------------------------
  // CALENDAR (UNCHANGED UI, LOGIC EXTENDED)
  // --------------------------------------------------
  Widget _buildCalendar() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    List<Widget> tiles = [];

    for (int i = 1; i < firstDay.weekday; i++) {
      tiles.add(const SizedBox());
    }

    for (int d = 1; d <= lastDay.day; d++) {
      final date = DateTime(now.year, now.month, d);
      final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                DateFormat("MMMM yyyy", locale).format(selectedDate),
                style: const TextStyle(
                    fontFamily: "PoppinsSemiBold", fontSize: 20),
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
                  "No slots available for today",
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
                                    staff: widget.staff,
                                    date: selectedDate,
                                    time: formattedTime,
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
                          borderRadius: BorderRadius.circular(15),
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
