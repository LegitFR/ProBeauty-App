import 'dart:convert';
import 'package:http/http.dart' as http;

class SalonService {
  static const String _baseUrl =
      "https://probeauty-backend.onrender.com/api/v1/salons";

  static Future<Map<String, dynamic>> fetchSalonById(String salonId) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/$salonId"),
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
