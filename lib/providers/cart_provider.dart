import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItemModel {
  final String id; // cartItem id
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
  int _totalItems = 0; // total quantity of all items

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

  /// --------------------------
  /// GET /api/v1/cart
  /// --------------------------
  Future<void> fetchCart() async {
    _setLoading(true);
    _error = null;

    try {
      final token = await _getToken();
      if (token == null) {
        _error = "No auth token found";
        _items = [];
        _subtotal = 0;
        _totalItems = 0;
        _setLoading(false);
        return;
      }

      final uri = Uri.parse("$_baseUrl/api/v1/cart");
      final resp = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body["data"] ?? {};
        final cart = data["cart"] ?? {};
        final List cartItemsJson = cart["cartItems"] ?? [];

        _items = cartItemsJson.map<CartItemModel>((item) {
          final product = item["product"] ?? {};
          final priceStr = product["price"]?.toString() ?? "0";
          final double price = double.tryParse(priceStr) ?? 0.0;

          return CartItemModel(
            id: item["id"] ?? "",
            productId: item["productId"] ?? product["id"] ?? "",
            title: product["title"] ?? "Product",
            price: price,
            quantity: item["quantity"] ?? 0,
          );
        }).toList();

        final summary = data["summary"] ?? {};
        _subtotal = (summary["subtotal"] != null)
            ? (summary["subtotal"] as num).toDouble()
            : _items.fold(
                0.0,
                (sum, it) => sum + (it.price * it.quantity),
              );

        _totalItems = (summary["totalItems"] != null)
            ? (summary["totalItems"] as num).toInt()
            : _items.fold(0, (sum, it) => sum + it.quantity);

        _error = null;
      } else {
        _error = "Failed to fetch cart (${resp.statusCode})";
      }
    } catch (e) {
      _error = "Error fetching cart: $e";
    }

    _setLoading(false);
  }

  /// --------------------------
  /// POST /api/v1/cart/items
  /// Used when adding more of a new product from ProductScreen
  /// --------------------------
  Future<String?> addItem({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return "No auth token found";

      final uri = Uri.parse("$_baseUrl/api/v1/cart/items");
      final body = {
        "productId": productId,
        "quantity": quantity,
      };

      final resp = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        await fetchCart();
        return null;
      } else {
        try {
          final j = jsonDecode(resp.body);
          return j["message"]?.toString() ?? "Failed to add item to cart";
        } catch (_) {
          return "Failed to add item to cart (${resp.statusCode})";
        }
      }
    } catch (e) {
      return "Error adding item: $e";
    }
  }

  /// --------------------------
  /// PATCH /api/v1/cart/items/:productId
  /// --------------------------
  Future<String?> updateItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeItem(productId: productId);
    }

    try {
      final token = await _getToken();
      if (token == null) return "No auth token found";

      final uri = Uri.parse("$_baseUrl/api/v1/cart/items/$productId");

      final body = {"quantity": quantity};

      final resp = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        await fetchCart();
        return null;
      } else {
        try {
          final j = jsonDecode(resp.body);
          return j["message"]?.toString() ?? "Failed to update cart item";
        } catch (_) {
          return "Failed to update cart item (${resp.statusCode})";
        }
      }
    } catch (e) {
      return "Error updating cart item: $e";
    }
  }

  /// --------------------------
  /// DELETE /api/v1/cart/items/:productId
  /// --------------------------
  Future<String?> removeItem({required String productId}) async {
    try {
      final token = await _getToken();
      if (token == null) return "No auth token found";

      final uri = Uri.parse("$_baseUrl/api/v1/cart/items/$productId");

      final resp = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode == 200) {
        await fetchCart();
        return null;
      } else {
        try {
          final j = jsonDecode(resp.body);
          return j["message"]?.toString() ?? "Failed to remove cart item";
        } catch (_) {
          return "Failed to remove cart item (${resp.statusCode})";
        }
      }
    } catch (e) {
      return "Error removing cart item: $e";
    }
  }

  Future<String?> checkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        return "No token found";
      }

      // --------------------------------------------------------
      // 1️⃣ Get all addresses
      // --------------------------------------------------------
      final addressUrl =
          Uri.parse("https://probeauty-backend.onrender.com/api/v1/addresses");

      final addressResp = await http.get(
        addressUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📬 ADDRESS RESPONSE: ${addressResp.statusCode}");
      print("📥 ADDRESS BODY: ${addressResp.body}");

      if (addressResp.statusCode != 200) {
        return "Failed to fetch address list";
      }

      final addressData = jsonDecode(addressResp.body);
      final List addresses = addressData["data"] ?? [];

      // find default address
      final defaultAddress = addresses.firstWhere(
        (a) => a["isDefault"] == true,
        orElse: () => null,
      );

      if (defaultAddress == null) {
        return "No default address found";
      }

      final String addressId = defaultAddress["id"];

      // --------------------------------------------------------
      // 2️⃣ Prepare order payload
      // --------------------------------------------------------
      final orderBody = {
        "addressId": addressId,
        "notes": "Please deliver between 2-5 PM"
      };

      print("📦 ORDER PAYLOAD: $orderBody");

      // --------------------------------------------------------
      // 3️⃣ Call Checkout endpoint
      // --------------------------------------------------------
      final orderUrl =
          Uri.parse("https://probeauty-backend.onrender.com/api/v1/orders");

      final resp = await http.post(
        orderUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(orderBody),
      );

      print("📤 CHECKOUT RESPONSE CODE: ${resp.statusCode}");
      print("📥 CHECKOUT RESPONSE BODY: ${resp.body}");

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return null; // success
      } else {
        return jsonDecode(resp.body)['message'] ?? "Checkout failed";
      }
    } catch (e) {
      print("❌ CHECKOUT ERROR: $e");
      return "Error: $e";
    }
  }
}
