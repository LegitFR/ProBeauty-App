import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/models/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentProvider with ChangeNotifier {
  static const String _baseUrl =
      "https://probeauty-backend.onrender.com/api/v1/bookings";

  bool _isLoading = false;
  bool _hasFetchedOnce = false;

  List<Booking> _bookings = [];

  bool get isLoading => _isLoading;
  List<Booking> get bookings => _bookings;

  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (_hasFetchedOnce && !forceRefresh) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      debugPrint("ACCESS TOKEN: $token");

      if (token == null) {
        debugPrint("NO TOKEN FOUND");
        _bookings = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("STATUS CODE: ${res.statusCode}");
      debugPrint("RESPONSE BODY: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded["data"] ?? [];

        debugPrint("RAW LIST LENGTH: ${data.length}");

        final bookings = data.map((e) {
          debugPrint("PARSING BOOKING: $e");
          return Booking.fromJson(e);
        }).toList();

        bookings.sort((a, b) => b.startTime.compareTo(a.startTime));

        _bookings = bookings;
        _hasFetchedOnce = true;
      }
    } catch (e, st) {
      debugPrint("Fetch bookings error: $e");
      debugPrintStack(stackTrace: st);
    }

    _isLoading = false;
    notifyListeners();
  }
}
