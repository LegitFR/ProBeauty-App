import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/models/booking.dart';
import 'package:probeauty_app/services/api_client.dart';

class AppointmentProvider with ChangeNotifier {
  static const String _endpoint = "/api/v1/bookings";

  bool _isLoading = true;
  bool _hasFetchedOnce = false;

  List<Booking> _bookings = [];

  bool get isLoading => _isLoading;
  List<Booking> get bookings => _bookings;

  Future<void> fetchBookings({bool forceRefresh = false}) async {
    if (_hasFetchedOnce && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.get(_endpoint);
      print("STATUS AND BODY");
      print(res.statusCode);
      print(res.body);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data = decoded["data"] ?? [];

        final List<Booking> bookings = [];

        for (final item in data) {
          try {
            print("RAW BOOKING ITEM:");
            print(item);

            bookings.add(Booking.fromJson(item));

            print("BOOKING PARSED SUCCESS");
          } catch (e, st) {
            print("BOOKING PARSE ERROR");
            print(e);
            print(st);
            print(item);
          }
        }

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
