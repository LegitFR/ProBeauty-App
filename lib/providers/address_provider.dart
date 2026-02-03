import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:probeauty_app/models/address.dart';
import 'package:probeauty_app/services/api_client.dart';

class AddressProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  bool _loading = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _loading;
  String? get error => _error;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // ======================
  // FETCH ALL
  // ======================
  Future<void> fetchAddresses() async {
    _loading = true;
    notifyListeners();

    try {
      final res = await ApiClient.get("/api/v1/addresses");

      final body = jsonDecode(res.body);
      final List data = body["data"];

      _addresses = data.map((e) => AddressModel.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = "Failed to load addresses";
    }

    _loading = false;
    notifyListeners();
  }

  // ======================
  // SET DEFAULT
  // ======================
  Future<void> setDefault(String id) async {
    try {
      await ApiClient.patch("/api/v1/addresses/$id/set-default");
      await fetchAddresses();
    } catch (_) {}
  }

  // ======================
  // DELETE
  // ======================
  Future<void> deleteAddress(String id) async {
    try {
      await ApiClient.delete("/api/v1/addresses/$id");
      await fetchAddresses();
    } catch (_) {}
  }

  // ======================
  // CREATE
  // ======================
  Future<void> createAddress(Map<String, dynamic> data) async {
    await ApiClient.post("/api/v1/addresses", body: data);
    await fetchAddresses();
  }

  // ======================
  // UPDATE
  // ======================
  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    await ApiClient.patch("/api/v1/addresses/$id", body: data);
    await fetchAddresses();
  }
}
