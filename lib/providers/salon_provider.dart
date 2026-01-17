import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/config/api_config.dart';

class SalonProvider with ChangeNotifier {
  final List<dynamic> _salons = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  final Map<String, Map<String, dynamic>> _ratingCache = {};

  // ================= GETTERS =================
  List<dynamic> get salons => List.unmodifiable(_salons);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Map<String, dynamic>? getSalonRating(String salonId) {
    return _ratingCache[salonId];
  }

  Future<void> fetchSalonRating(String salonId) async {
    if (_ratingCache.containsKey(salonId)) return;

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}/api/v1/reviews/salon/$salonId?page=1&limit=1",
      );

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        _ratingCache[salonId] = {
          "avgRating": (body["averageRating"] ?? 0).toDouble(),
          "totalReviews": body["pagination"]?["total"] ?? 0,
        };

        notifyListeners();
      }
    } catch (_) {
      // silent fail
    }
  }

  // ================= CORE FETCH =================
  Future<void> fetchSalons({
    bool refresh = false,
    bool showLoader = true, // 🔥 silent refresh support
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _salons.clear();
      _currentPage = 1;
      _hasMore = true;
      if (showLoader) notifyListeners();
    }

    _isLoading = true;
    if (showLoader) notifyListeners();

    try {
      // 🔥 Keep fetching until backend sends empty page
      while (_hasMore) {
        final url = Uri.parse(
          "${ApiConfig.baseUrl}/api/v1/salons?page=$_currentPage",
        );

        final res = await http.get(url);

        if (res.statusCode != 200) {
          _hasMore = false;
          break;
        }

        final decoded = jsonDecode(res.body);
        final List newSalons = decoded["data"] ?? [];

        if (newSalons.isEmpty) {
          _hasMore = false;
          break;
        }

        _salons.addAll(newSalons);
        _currentPage++;

        // 🔥 Live update UI as pages stream in
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Fetch salons error: $e");
    } finally {
      _isLoading = false;
      if (showLoader) notifyListeners();
    }
  }

  // ================= MANUAL REFRESH =================
  Future<void> hardRefresh() async {
    await fetchSalons(refresh: true, showLoader: true);
  }

  // ================= UTIL =================
  void clearSalons() {
    _salons.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
