import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/config/api_config.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  // ================= ENDPOINTS =================
  static const String _productsEndpoint = "/api/v1/products";
  static const String _searchEndpoint = "/api/v1/products/search";
  static const String _salonEndpoint = "/api/v1/salons";

  // ================= STATE =================
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> searchResults = [];
  bool isSearching = false;
  String? searchError;

  // salonId → salonName cache
  final Map<String, String> _salonNames = {};

  // ================= GETTERS =================
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get salonNames => _salonNames;

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}$_productsEndpoint",
      );

      final res = await http.get(uri);
      final body = json.decode(res.body);
      final data = body['data'];

      if (data is List) {
        _products = data.map((e) => Product.fromJson(e)).toList();
        await _fetchSalonNames();
      } else {
        _error = 'Unexpected response';
      }
    } catch (_) {
      _error = 'Failed to fetch products';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= SALON NAME CACHE =================
  Future<void> _fetchSalonNames() async {
    final uniqueSalonIds = _products
        .map((p) => p.salonId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    for (final id in uniqueSalonIds) {
      if (_salonNames.containsKey(id)) continue;

      try {
        final uri = Uri.parse(
          "${ApiConfig.baseUrl}$_salonEndpoint/$id",
        );

        final res = await http.get(uri);

        if (res.statusCode == 200) {
          final body = json.decode(res.body);
          _salonNames[id!] = body['data']?['name'] ?? 'Salon';
        } else {
          _salonNames[id!] = 'Salon';
        }
      } catch (_) {
        _salonNames[id!] = 'Salon';
      }
    }
  }

  // ================= SEARCH =================
  Future<void> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return;

    isSearching = true;
    searchError = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "${ApiConfig.baseUrl}$_searchEndpoint"
        "?q=${Uri.encodeQueryComponent(query)}"
        "&page=$page&limit=$limit",
      );

      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body["data"] ?? [];

        searchResults = data.map<Product>((e) => Product.fromJson(e)).toList();
      } else {
        searchError = "Search failed";
      }
    } catch (e) {
      searchError = "Something went wrong";
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  // ================= UTIL =================
  void clearProducts() {
    _products.clear();
    _salonNames.clear();
    _error = null;
    notifyListeners();
  }
}
