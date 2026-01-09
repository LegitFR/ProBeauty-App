import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalonProvider with ChangeNotifier {
  List<dynamic> _salons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<dynamic> get salons => _salons;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchSalons({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _salons.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        "https://probeauty-backend.onrender.com/api/v1/salons?page=$_currentPage",
      );

      final res = await http.get(url);
      final data = jsonDecode(res.body);
      final List newSalons = data["data"] ?? [];

      if (newSalons.isEmpty) {
        _hasMore = false;
      } else {
        _salons.addAll(newSalons);
        _currentPage++;
      }
    } catch (_) {
      // handle error silently or expose later
    }

    _isLoading = false;
    notifyListeners();
  }
}
