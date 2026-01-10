import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExploreProvider with ChangeNotifier {
  final String _baseUrl = "https://probeauty-backend.onrender.com";

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
      final resp = await http.get(Uri.parse("$_baseUrl/api/v1/services"));

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
    }

    isLoadingServices = false;
    notifyListeners();
  }

  /// Optional: manual refresh
  Future<void> refreshServices() async {
    _hasFetchedOnce = false;
    services.clear();
    await fetchServices();
  }
}
