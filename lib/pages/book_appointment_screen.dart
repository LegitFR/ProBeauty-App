import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:probeauty_app/resources/AppColors.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> staff; // ONE staff object
  final List<Map<String, dynamic>> selectedServices; // LIST of service objects

  const BookAppointmentScreen({
    super.key,
    required this.staff,
    required this.selectedServices,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  List<String> availableTimes = [];

  @override
  void initState() {
    super.initState();
    _generateTimesForDate(selectedDate);
  }

  // Convert weekday number -> "monday", "tuesday"...
  String _weekdayToKey(int weekday) {
    return [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ][weekday - 1];
  }

  // Generate half-hour slots for given date
  void _generateTimesForDate(DateTime date) {
    availableTimes = [];
    final dayKey = _weekdayToKey(date.weekday);

    final availability = widget.staff["availability"][dayKey];

    // If format doesn’t match → stop
    if (availability == null || availability is! Map) {
      setState(() {});
      return;
    }

    final bool isAvailable = availability["isAvailable"] == true;
    final slots = availability["slots"];

    if (!isAvailable || slots == null || slots is! List) {
      setState(() {});
      return;
    }

    for (var slot in slots) {
      if (slot is Map && slot["start"] != null && slot["end"] != null) {
        availableTimes.addAll(
          _generateHalfHourSlots(slot["start"], slot["end"], date),
        );
      }
    }

    setState(() {});
  }

  // Create 30-minute slots, skip past times if it's today
  List<String> _generateHalfHourSlots(String start, String end, DateTime date) {
    final fmt = DateFormat("HH:mm");
    DateTime s = fmt.parse(start);
    DateTime e = fmt.parse(end);

    DateTime cursor =
        DateTime(date.year, date.month, date.day, s.hour, s.minute);
    DateTime limit =
        DateTime(date.year, date.month, date.day, e.hour, e.minute);

    List<String> slots = [];

    final now = DateTime.now();

    while (cursor.isBefore(limit)) {
      if (!(isSameDay(cursor, now) && cursor.isBefore(now))) {
        slots.add(fmt.format(cursor));
      }
      cursor = cursor.add(const Duration(minutes: 30));
    }

    return slots;
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Display 10:30 AM format
  String displayTime(String hhmm) {
    final dt = DateFormat("HH:mm").parse(hhmm);
    return DateFormat("hh:mm a").format(dt).toLowerCase();
  }

  // Build calendar for CURRENT month only
  Widget _buildCalendar() {
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
      final isSelected = isSameDay(date, selectedDate);

      tiles.add(
        GestureDetector(
          onTap: isPast
              ? null
              : () {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null;
                  });
                  _generateTimesForDate(date);
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
                  color: isSelected
                      ? Colors.white
                      : isPast
                          ? Colors.grey
                          : Colors.black,
                  fontFamily: "PoppinsSemiBold",
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softIvory,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.softIvory,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          "Book an appointment",
          style: TextStyle(fontFamily: "PoppinsSemiBold", color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MONTH HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              DateFormat("MMMM yyyy").format(DateTime.now()),
              style: const TextStyle(
                fontFamily: "PoppinsSemiBold",
                fontSize: 20,
              ),
            ),
          ),

          // CALENDAR
          _buildCalendar(),

          const Divider(thickness: 1),

          // TIME SLOTS
          SizedBox(
            height: 70,
            child: availableTimes.isEmpty
                ? const Center(
                    child: Text("No available slots",
                        style: TextStyle(fontFamily: "PoppinsRegular")))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: availableTimes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final t = availableTimes[i];
                      final selected = t == selectedTime;

                      return GestureDetector(
                        onTap: () => setState(() => selectedTime = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black),
                            color: selected
                                ? AppColors.rusticSunset
                                : Colors.white,
                          ),
                          child: Text(
                            displayTime(t),
                            style: TextStyle(
                              fontFamily: "PoppinsSemiBold",
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 18),

          // SELECTED SERVICE SUMMARY LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: widget.selectedServices
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _serviceTile(s),
                      ))
                  .toList(),
            ),
          ),

          // ADD ANOTHER SERVICE
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                "+ Add another service",
                style: TextStyle(
                  color: AppColors.rusticSunset,
                  fontFamily: "PoppinsSemiBold",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTile(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.softIvory,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black12,
            radius: 20,
            child: Icon(Icons.cut, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s["title"],
                    style: const TextStyle(
                        fontFamily: "PoppinsSemiBold", fontSize: 15)),
                const SizedBox(height: 4),
                Text("${s["durationMinutes"]} mins",
                    style: const TextStyle(
                        fontFamily: "PoppinsRegular",
                        fontSize: 13,
                        color: Colors.black54)),
              ],
            ),
          ),
          Text(
            "₹${s["price"]}",
            style: const TextStyle(fontFamily: "PoppinsSemiBold", fontSize: 15),
          ),
        ],
      ),
    );
  }
}
