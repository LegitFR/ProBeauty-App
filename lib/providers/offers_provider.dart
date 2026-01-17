import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/services/api_client.dart';

class OfferProvider with ChangeNotifier {
  // ================= ENDPOINT =================
  static const String _offersEndpoint = "/api/v1/offers/public/active";

  bool _isLoading = false;
  int _page = 1;
  int _totalPages = 1;
  final int _limit = 10;

  final List<Map<String, dynamic>> _offers = [];

  // ================= GETTERS =================
  bool get isLoading => _isLoading;
  bool get hasMore => _page <= _totalPages;

  List<Map<String, dynamic>> get offers => List.unmodifiable(_offers);

  List<Map<String, dynamic>> get salonOffers =>
      _offers.where((o) => o["offerType"] == "salon").toList();

  List<Map<String, dynamic>> get productOffers =>
      _offers.where((o) => o["offerType"] == "product").toList();

  // ================= CORE FETCH =================
  Future<void> fetchActiveOffers({
    bool reset = false,
    bool showLoader = true, // 🔥 controls skeleton flicker
  }) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      _offers.clear();
      if (showLoader) notifyListeners();
    }

    if (!hasMore) return;

    _isLoading = true;
    if (showLoader) notifyListeners();

    try {
      final response = await ApiClient.get(
        _offersEndpoint,
        query: {
          "page": _page.toString(),
          "limit": _limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded["data"] ?? [];
        final pagination = decoded["pagination"];

        _totalPages = pagination?["totalPages"] ?? 1;

        final newOffers = data.cast<Map<String, dynamic>>();

        // 🔥 Only update UI if new data actually arrived
        if (newOffers.isNotEmpty) {
          _offers.addAll(newOffers);
          _page++;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Offer fetch error: $e");
    } finally {
      _isLoading = false;
      if (showLoader) notifyListeners();
    }
  }

  // ================= FILTERED FETCH =================
  Future<void> fetchOffersByFilter({
    String? salonId,
    String? productId,
    String? serviceId,
    bool reset = true,
    bool showLoader = true,
  }) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      _offers.clear();
      if (showLoader) notifyListeners();
    }

    _isLoading = true;
    if (showLoader) notifyListeners();

    try {
      final query = {
        "page": _page.toString(),
        "limit": _limit.toString(),
        if (salonId != null) "salonId": salonId,
        if (productId != null) "productId": productId,
        if (serviceId != null) "serviceId": serviceId,
      };

      final response = await ApiClient.get(
        _offersEndpoint,
        query: query.map((k, v) => MapEntry(k, v.toString())),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data = decoded["data"] ?? [];
        final pagination = decoded["pagination"];

        _totalPages = pagination?["totalPages"] ?? 1;

        final newOffers = data.cast<Map<String, dynamic>>();

        // 🔥 Only notify UI if something changed
        if (newOffers.isNotEmpty) {
          _offers.addAll(newOffers);
          _page++;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Offer fetch error: $e");
    } finally {
      _isLoading = false;
      if (showLoader) notifyListeners();
    }
  }

  // ================= MANUAL REFRESH =================
  Future<void> hardRefresh() async {
    await fetchActiveOffers(reset: true, showLoader: true);
  }

  // ================= UTIL =================
  void clearOffers() {
    _page = 1;
    _totalPages = 1;
    _offers.clear();
    notifyListeners();
  }
}
