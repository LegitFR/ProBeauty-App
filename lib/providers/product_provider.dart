import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  static const String _baseUrl = 'https://probeauty-backend.onrender.com';
  static const String _productsEndpoint = '$_baseUrl/api/v1/products';

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // salonId → salonName cache
  final Map<String, String> _salonNames = {};

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get salonNames => _salonNames;

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse(_productsEndpoint));
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
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchSalonNames() async {
    final uniqueSalonIds = _products
        .map((p) => p.salonId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    for (final id in uniqueSalonIds) {
      if (_salonNames.containsKey(id)) continue;

      try {
        final res = await http.get(
          Uri.parse('$_baseUrl/api/v1/salons/$id'),
        );

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
}
