import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  static const String _baseUrl = "https://probeauty-backend.onrender.com";

  bool _isLoading = false;
  String? _error;

  List<CartItemModel> _items = [];
  double _subtotal = 0.0;
  int _totalItems = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CartItemModel> get items => _items;
  double get subtotal => _subtotal;
  int get totalItems => _totalItems;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // ==========================================================
  // GET CART
  // ==========================================================
  Future<void> fetchCart() async {
    _setLoading(true);
    _error = null;

    try {
      final token = await _getToken();
      if (token == null) throw Exception("No auth token");

      final resp = await http.get(
        Uri.parse("$_baseUrl/api/v1/cart"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode != 200) {
        throw Exception("Failed to fetch cart (${resp.statusCode})");
      }

      final body = jsonDecode(resp.body);
      final cart = body["data"]?["cart"];
      final summary = body["data"]?["summary"];

      if (cart == null) throw Exception("Invalid cart response");

      final List cartItemsJson = cart["cartItems"] ?? [];

      _items = cartItemsJson.map<CartItemModel>((item) {
        final product = item["product"] ?? {};
        final price =
            double.tryParse(product["price"]?.toString() ?? "0") ?? 0.0;

        return CartItemModel(
          id: item["id"],
          productId: item["productId"] ?? product["id"],
          title: product["title"] ?? "Product",
          price: price,
          quantity: item["quantity"] ?? 0,
        );
      }).toList();

      _subtotal = summary?["subtotal"] != null
          ? (summary["subtotal"] as num).toDouble()
          : _items.fold(0.0, (s, i) => s + (i.price * i.quantity));

      _totalItems = summary?["totalItems"] != null
          ? (summary["totalItems"] as num).toInt()
          : _items.fold(0, (s, i) => s + i.quantity);
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ==========================================================
  // UPDATE / REMOVE ITEMS
  // ==========================================================
  Future<String?> removeItem({required String productId}) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("No auth token");

      final resp = await http.delete(
        Uri.parse("$_baseUrl/api/v1/cart/items/$productId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (resp.statusCode != 200) {
        return jsonDecode(resp.body)["message"];
      }

      await fetchCart();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeItem(productId: productId);
    }

    try {
      final token = await _getToken();
      if (token == null) throw Exception("No auth token");

      final resp = await http.patch(
        Uri.parse("$_baseUrl/api/v1/cart/items/$productId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"quantity": quantity}),
      );

      if (resp.statusCode != 200) {
        return jsonDecode(resp.body)["message"];
      }

      await fetchCart();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================================================
  // STRIPE CHECKOUT (STEP 1–5)
  // ==========================================================
  Future<Map<String, dynamic>?> checkoutWithStripe() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("No auth token");

      final addressResp = await http.get(
        Uri.parse("$_baseUrl/api/v1/addresses"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (addressResp.statusCode != 200) {
        throw Exception("Failed to fetch addresses");
      }

      final addresses = jsonDecode(addressResp.body)["data"] as List;
      final defaultAddress = addresses.firstWhere(
        (a) => a["isDefault"] == true,
        orElse: () => null,
      );

      if (defaultAddress == null) {
        throw Exception("No default address found");
      }

      final resp = await http.post(
        Uri.parse("$_baseUrl/api/v1/orders/checkout"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"addressId": defaultAddress["id"]}),
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception(jsonDecode(resp.body)["message"]);
      }

      final data = jsonDecode(resp.body)["data"];
      final order = data["order"];

      if (order == null || data["clientSecret"] == null) {
        throw Exception("Invalid checkout response");
      }

      return {
        "orderId": order["id"],
        "clientSecret": data["clientSecret"],
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ==========================================================
  // STRIPE CONFIRM PAYMENT (STEP 6–7)
  // ==========================================================
  Future<bool> confirmStripePayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ProBeauty',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      _error = e.error.message ?? "Payment cancelled";
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================================
  // POLL ORDER STATUS (STEP 12)
  // ==========================================================
  Future<String?> pollOrderStatus(String orderId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final resp = await http.get(
        Uri.parse("$_baseUrl/api/v1/orders/$orderId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (resp.statusCode != 200) return null;

      return jsonDecode(resp.body)["data"]["status"];
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // LEGACY CHECKOUT (UNCHANGED)
  // ==========================================================
  Future<String?> checkout() async {
    try {
      final token = await _getToken();
      if (token == null) return "No token found";

      final addressResp = await http.get(
        Uri.parse("$_baseUrl/api/v1/addresses"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final addresses = jsonDecode(addressResp.body)["data"] as List;
      final defaultAddress = addresses.firstWhere(
        (a) => a["isDefault"] == true,
        orElse: () => null,
      );

      if (defaultAddress == null) return "No default address";

      final resp = await http.post(
        Uri.parse("$_baseUrl/api/v1/orders"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"addressId": defaultAddress["id"]}),
      );

      return resp.statusCode == 200 || resp.statusCode == 201
          ? null
          : "Checkout failed";
    } catch (e) {
      return e.toString();
    }
  }
}
