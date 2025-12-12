// lib/providers/order_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderModel {
  final String id;
  final String salonId;
  final String salonName;
  final String title;
  final double price;
  final int quantity;
  final String status;

  OrderModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.title,
    required this.price,
    required this.quantity,
    required this.status,
  });
}

class OrderProvider with ChangeNotifier {
  static const String _baseUrl = "https://probeauty-backend.onrender.com";

  bool isLoading = false;
  String? error;
  List<OrderModel> orders = [];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        error = "No token found";
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse("$_baseUrl/api/v1/orders");
      final resp = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final List data = json["data"] ?? [];

        orders = data.map<OrderModel>((o) {
          final items = o["orderItems"];
          final firstItem =
              (items != null && items.isNotEmpty) ? items[0] : null;
          final product = firstItem?["product"] ?? {};

          return OrderModel(
            id: o["id"],
            salonId: o["salonId"] ?? "",
            salonName: product["title"] != null
                ? product["title"].toString().split(" ").first
                : "Salon",
            title: product["title"] ?? "Product",
            price: double.tryParse(product["price"] ?? "0") ?? 0,
            quantity: firstItem?["quantity"] ?? 1,
            status: o["status"] ?? "",
          );
        }).toList();
      } else {
        error = "Failed to load orders";
      }
    } catch (e) {
      error = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
