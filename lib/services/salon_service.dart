import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:probeauty_app/config/api_config.dart';

class SalonService {
  static Future<Map<String, dynamic>> fetchSalonById(String salonId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/v1/salons/$salonId"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded["data"];
    } else {
      throw Exception("Failed to fetch salon");
    }
  }
}
