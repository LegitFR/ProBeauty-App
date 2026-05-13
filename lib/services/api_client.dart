import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probeauty_app/config/api_config.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 20);

  // =====================
  // PUBLIC METHODS
  // =====================

  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
  }) {
    return _send(
      method: "GET",
      path: path,
      query: query,
    );
  }

  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send(
      method: "POST",
      path: path,
      body: body,
      query: query,
    );
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? query,
  }) {
    return _send(
      method: "DELETE",
      path: path,
      query: query,
    );
  }

  static Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send(
      method: "PATCH",
      path: path,
      body: body,
      query: query,
    );
  }

  static Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send(
      method: "PUT",
      path: path,
      body: body,
      query: query,
    );
  }
  // =====================
  // CORE ENGINE
  // =====================

  static Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool retry = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("accessToken");

    final uri = Uri.parse("${ApiConfig.baseUrl}$path").replace(
      queryParameters: query,
    );

    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (accessToken != null) "Authorization": "Bearer $accessToken",
    };

    late http.Response response;

    try {
      switch (method) {
        case "POST":
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeout);
          break;

        case "PATCH":
          response = await http
              .patch(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeout);
          break;

        case "PUT":
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeout);
          break;

        case "DELETE":
          response = await http
              .delete(
                uri,
                headers: headers,
              )
              .timeout(_timeout);
          break;

        default: // GET
          response = await http
              .get(
                uri,
                headers: headers,
              )
              .timeout(_timeout);
      }
    } catch (e) {
      rethrow;
    }

    // =====================
    // TOKEN EXPIRED → REFRESH & RETRY
    // =====================
    if (response.statusCode == 401 && retry) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return _send(
          method: method,
          path: path,
          body: body,
          query: query,
          retry: false,
        );
      }
    }

    return response;
  }

  // =====================
  // REFRESH TOKEN LOGIC
  // =====================

  static Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString("refreshToken");

    if (refreshToken == null) return false;

    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/api/v1/auth/refresh-token",
    );

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refreshToken": refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data["accessToken"];

        if (newAccessToken != null) {
          await prefs.setString("accessToken", newAccessToken);
          return true;
        }
      }
    } catch (_) {}

    // ❌ Refresh failed → logout user
    await _clearSession();
    return false;
  }

  // =====================
  // SESSION RESET
  // =====================

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    await prefs.remove("userId");
    await prefs.remove("userName");
    await prefs.remove("userEmail");
    await prefs.remove("userPhone");
  }
}
