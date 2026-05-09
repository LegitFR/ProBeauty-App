import 'package:probeauty_app/models/salon.dart';
import 'package:probeauty_app/models/service.dart';
import 'package:probeauty_app/models/staff.dart';

class Booking {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  final Salon salon;

  /// ✅ MULTIPLE SERVICES
  final List<Service> services;

  final Staff? staff;

  Booking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.salon,
    required this.services,
    this.staff,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["id"],

      startTime: DateTime.parse(json["startTime"]),

      endTime: DateTime.parse(json["endTime"]),

      status: json["status"],

      salon: Salon.fromJson(json["salon"]),

      /// ✅ PARSE MULTIPLE SERVICES
      services: (json["services"] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],

      /// ✅ NULL SAFE STAFF
      staff: json["staff"] != null ? Staff.fromJson(json["staff"]) : null,
    );
  }
}
