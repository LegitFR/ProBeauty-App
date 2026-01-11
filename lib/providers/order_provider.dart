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
  final String image;

  OrderModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.title,
    required this.price,
    required this.quantity,
    required this.status,
    required this.image,
  });

  // ✅ ADD THIS
  OrderModel copyWith({
    String? status,
  }) {
    return OrderModel(
      id: id,
      salonId: salonId,
      salonName: salonName,
      title: title,
      price: price,
      quantity: quantity,
      status: status ?? this.status,
      image: image,
    );
  }
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
            price: double.tryParse(product["price"]?.toString() ?? "0") ?? 0,
            quantity: firstItem?["quantity"] ?? 1,
            status: o["status"] ?? "",
            image: product["images"][0] ?? "",
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

  Future<void> cancelOrder(String orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("Not authenticated");
      }

      final url = Uri.parse(
        "$_baseUrl/api/v1/orders/$orderId/cancel",
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Update local order status
        final index = orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          orders[index] = orders[index].copyWith(
            status: "CANCELLED",
          );
        }

        notifyListeners();
      } else {
        throw Exception(body["message"] ?? "Failed to cancel order");
      }
    } catch (e) {
      rethrow;
    }
  }
}
