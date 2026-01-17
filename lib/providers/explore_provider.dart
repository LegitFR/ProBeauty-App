import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/config/api_config.dart';

class ExploreProvider with ChangeNotifier {
  // ================= ENDPOINT =================
  static const String _servicesEndpoint = "/api/v1/services";

  bool isLoadingServices = false;
  String? error;

  List<Map<String, String>> services = [];

  bool _hasFetchedOnce = false;

  Future<void> fetchServices() async {
    if (_hasFetchedOnce) return;

    isLoadingServices = true;
    error = null;
    notifyListeners();

    const fallbackImages = [
      "assets/images/services/hair_styling.png",
      "assets/images/services/ayurvedic.png",
      "assets/images/services/eyebrow.png",
      "assets/images/services/makeup.png",
    ];

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}$_servicesEndpoint",
      );

      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final List data = json["data"] ?? [];

        services = data.asMap().entries.map<Map<String, String>>((entry) {
          final index = entry.key;
          final s = entry.value;

          final apiImage = s["image"];

          return {
            "id": s["id"],
            "title": s["title"] ?? "Service",
            "img": (apiImage != null && apiImage.toString().isNotEmpty)
                ? apiImage.toString()
                : fallbackImages[index % fallbackImages.length],
          };
        }).toList();

        _hasFetchedOnce = true;
      } else {
        error = "Failed to load services";
      }
    } catch (e) {
      error = "Error: $e";
    } finally {
      isLoadingServices = false;
      notifyListeners();
    }
  }

  /// Optional: manual refresh
  Future<void> refreshServices() async {
    _hasFetchedOnce = false;
    services.clear();
    await fetchServices();
  }
}
