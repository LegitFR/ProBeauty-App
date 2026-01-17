import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/models/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/config/api_config.dart';

class AppointmentProvider with ChangeNotifier {
  static const String _endpoint = "/api/v1/bookings";

  bool _isLoading = true; // 🔥 MUST start true
  bool _hasFetchedOnce = false;

  List<Booking> _bookings = [];

  bool get isLoading => _isLoading;
  List<Booking> get bookings => _bookings;

  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (_hasFetchedOnce && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        _bookings = [];
        _hasFetchedOnce = true;
        return;
      }

      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}$_endpoint"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded["data"] ?? [];

        final bookings = data.map((e) => Booking.fromJson(e)).toList();

        bookings.sort((a, b) => b.startTime.compareTo(a.startTime));

        _bookings = bookings;
      } else {
        _bookings = [];
      }

      _hasFetchedOnce = true;
    } catch (e, st) {
      debugPrint("Fetch bookings error: $e");
      debugPrintStack(stackTrace: st);
      _bookings = [];
      _hasFetchedOnce = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: manual refresh
  Future<void> refresh() async {
    _hasFetchedOnce = false;
    await fetchBookings(forceRefresh: true);
  }
}
