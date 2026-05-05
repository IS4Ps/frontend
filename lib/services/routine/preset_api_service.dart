import 'package:http/http.dart' as http;
import 'dart:convert';

class PresetApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  Future<http.Response> createPreset(Map<String, dynamic> body, String token) async {
    final url = Uri.parse('$baseUrl/api/v1/presets');
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}