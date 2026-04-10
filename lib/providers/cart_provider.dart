import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:probeauty_app/models/cart_item.dart';
import 'package:probeauty_app/services/api_client.dart';

class CartProvider with ChangeNotifier {
  // ================= ENDPOINTS =================
  static const String _cartEndpoint = "/api/v1/cart";
  static const String _cartItemEndpoint = "/api/v1/cart/items";
  static const String _addressesEndpoint = "/api/v1/addresses";
  static const String _ordersEndpoint = "/api/v1/orders";
  static const String _checkoutEndpoint = "/api/v1/orders/checkout";

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

  // ==========================================================
  // GET CART
  // ==========================================================
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    _error = null;

    try {
      final resp = await ApiClient.get(_cartEndpoint);

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

    _isLoading = false;

    /// 🔥 SINGLE NOTIFY
    notifyListeners();
  }

  // ==========================================================
  // UPDATE / REMOVE ITEMS
  // ==========================================================
  Future<String?> removeItem({required String productId}) async {
    try {
      final resp = await ApiClient.delete("$_cartItemEndpoint/$productId");

      if (resp.statusCode != 200) {
        return jsonDecode(resp.body)["message"];
      }

      _items.removeWhere((item) => item.productId == productId);

      _subtotal = _items.fold(0.0, (s, i) => s + (i.price * i.quantity));
      _totalItems = _items.fold(0, (s, i) => s + i.quantity);

      notifyListeners();

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
      final resp = await ApiClient.patch(
        "$_cartItemEndpoint/$productId",
        body: {
          "quantity": quantity,
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

  Future<String?> clearCart() async {
    try {
      final resp = await ApiClient.delete(_cartEndpoint);

      if (resp.statusCode != 200) {
        return jsonDecode(resp.body)["message"];
      }

      _items.clear();
      _subtotal = 0;
      _totalItems = 0;

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> addItem({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final resp = await ApiClient.post(
        _cartItemEndpoint,
        body: {
          "productId": productId,
          "quantity": quantity,
        },
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        return jsonDecode(resp.body)["message"];
      }

      await fetchCart();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> increaseQty({
    required String productId,
    required int currentQty,
  }) async {
    return updateItemQuantity(
      productId: productId,
      quantity: currentQty + 1,
    );
  }

  Future<String?> decreaseQty({
    required String productId,
    required int currentQty,
  }) async {
    if (currentQty <= 1) {
      return removeItem(productId: productId);
    }

    return updateItemQuantity(
      productId: productId,
      quantity: currentQty - 1,
    );
  }

  Future<Map<String, dynamic>?> checkoutWithIfThenPay({
    required String paymentMethod,
    String? mobileNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final addressResp = await ApiClient.get(_addressesEndpoint);

      if (addressResp.statusCode != 200) {
        throw Exception("Failed to fetch addresses");
      }

      final addresses = jsonDecode(addressResp.body)["data"] as List;
      final defaultAddress = addresses.cast<Map<String, dynamic>>().firstWhere(
            (a) => a["isDefault"] == true,
            orElse: () => {},
          );

      if (defaultAddress.isEmpty) {
        throw Exception("No default address found");
      }

      final body = {
        "addressId": defaultAddress["id"],
        "paymentMethod": paymentMethod,
      };

      // ✅ FIX: Proper MBWAY validation
      if (paymentMethod == "MBWAY") {
        if (mobileNumber == null || mobileNumber.isEmpty) {
          throw Exception("Mobile number required for MBWAY");
        }
        body["mobileNumber"] = mobileNumber;
      }

      final resp = await ApiClient.post(
        _checkoutEndpoint,
        body: body,
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception(jsonDecode(resp.body)["message"]);
      }

      // ✅ FIX: safer parsing
      final data = jsonDecode(resp.body)["data"] ?? {};

      return {
        "orderId": data["order"]?["id"],
        "payment": data["payment"],
      };
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      // ✅ FIX: loading state handled properly
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // POLL ORDER STATUS (STEP 12)
  // ==========================================================
  Future<String?> pollOrderStatus(String orderId) async {
    try {
      final resp = await ApiClient.get("$_ordersEndpoint/$orderId");

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
      final addressResp = await ApiClient.get(_addressesEndpoint);

      final addresses = jsonDecode(addressResp.body)["data"] as List;
      final defaultAddress = addresses.firstWhere(
        (a) => a["isDefault"] == true,
        orElse: () => null,
      );

      if (defaultAddress == null) return "No default address";

      final resp = await ApiClient.post(
        _ordersEndpoint,
        body: {"addressId": defaultAddress["id"]},
      );

      return resp.statusCode == 200 || resp.statusCode == 201
          ? null
          : "Checkout failed";
    } catch (e) {
      return e.toString();
    }
  }
}
