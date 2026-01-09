import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentProvider with ChangeNotifier {
  static const String _baseUrl =
      "https://probeauty-backend.onrender.com/api/v1/bookings";

  bool _isLoading = false;
  List<dynamic> _bookings = [];
  bool _hasFetchedOnce = false;

  bool get isLoading => _isLoading;
  List<dynamic> get bookings => _bookings;

  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (_hasFetchedOnce && !forceRefresh) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        _bookings = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data["data"] ?? [];

        list.sort((a, b) {
          return DateTime.parse(b["startTime"])
              .compareTo(DateTime.parse(a["startTime"]));
        });

        _bookings = list;
        _hasFetchedOnce = true;
      }
    } catch (_) {
      // silently fail or expose error later
    }

    _isLoading = false;
    notifyListeners();
  }
}
