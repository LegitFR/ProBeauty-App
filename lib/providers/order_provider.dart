import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:probeauty_app/models/order.dart';
import 'package:probeauty_app/services/api_client.dart';

// ================= PROVIDER =================
class OrderProvider with ChangeNotifier {
  static const String _ordersEndpoint = "/api/v1/orders";
  static const String _cancelEndpoint = "/api/v1/orders"; // + /{id}/cancel

  bool isLoading = false;
  String? error;
  List<OrderModel> orders = [];

  // ================= FETCH ORDERS =================
  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final resp = await ApiClient.get(
        _ordersEndpoint,
      );

      print(resp.body);

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
            image: (product["images"] is List && product["images"].isNotEmpty)
                ? product["images"][0]
                : "",
          );
        }).toList();
      } else {
        error = "Failed to load orders";
      }
    } catch (e) {
      print(error);
      error = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= CANCEL ORDER =================
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await ApiClient.post(
        "$_cancelEndpoint/$orderId/cancel",
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
