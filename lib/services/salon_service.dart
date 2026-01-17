import 'dart:convert';

import 'package:probeauty_app/services/api_client.dart';

class SalonService {
  static Future<Map<String, dynamic>> fetchSalonById(String salonId) async {
    final response = await ApiClient.get(
      "/api/v1/salons/$salonId",
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["data"];
    } else {
      throw Exception("Failed to fetch salon");
    }
  }
}
