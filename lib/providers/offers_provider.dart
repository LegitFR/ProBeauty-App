import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OfferProvider with ChangeNotifier {
  final String _baseUrl = "http://10.0.2.2:5000";

  bool _isLoading = false;
  int _page = 1;
  int _totalPages = 1;
  final int _limit = 10;

  final List<Map<String, dynamic>> _offers = [];

  // ================= GETTERS =================
  bool get isLoading => _isLoading;

  bool get hasMore => _page <= _totalPages;

  List<Map<String, dynamic>> get offers => _offers;

  List<Map<String, dynamic>> get salonOffers =>
      _offers.where((o) => o["offerType"] == "salon").toList();

  List<Map<String, dynamic>> get productOffers =>
      _offers.where((o) => o["offerType"] == "product").toList();

  // ================= PUBLIC API =================
  Future<void> fetchActiveOffers({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      _offers.clear();
    }

    if (!hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("$_baseUrl/api/v1/offers/public/active").replace(
        queryParameters: {
          "page": _page.toString(),
          "limit": _limit.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded["data"] ?? [];
        final pagination = decoded["pagination"];

        _totalPages = pagination?["totalPages"] ?? 1;

        _offers.addAll(
          data.cast<Map<String, dynamic>>(),
        );

        _page++;
      }
    } catch (e) {
      debugPrint("Offer fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= OPTIONAL FILTERED FETCH =================
  Future<void> fetchOffersByFilter({
    String? salonId,
    String? productId,
    String? serviceId,
    bool reset = true,
  }) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      _offers.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final query = {
        "page": _page.toString(),
        "limit": _limit.toString(),
        if (salonId != null) "salonId": salonId,
        if (productId != null) "productId": productId,
        if (serviceId != null) "serviceId": serviceId,
      };

      final uri = Uri.parse("$_baseUrl/api/v1/offers/public/active")
          .replace(queryParameters: query);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded["data"] ?? [];
        final pagination = decoded["pagination"];

        _totalPages = pagination?["totalPages"] ?? 1;

        _offers.addAll(
          data.cast<Map<String, dynamic>>(),
        );

        _page++;
      }
    } catch (e) {
      debugPrint("Offer fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
