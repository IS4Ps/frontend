import 'package:http/http.dart' as http;
import 'package:frontend/auth/token_manager.dart' as my_auth;
import 'dart:convert';

class MissionApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  String _getToken() {
    return my_auth.TokenManager().parentToken ?? my_auth.TokenManager().token ?? "";
  }

  Future<http.Response> createMission(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/v1/missions');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getToken()}',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getMissionsByDate(int childId, String date) async {
    final url = Uri.parse('$baseUrl/api/v1/missions?childId=$childId&date=$date');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer ${_getToken()}'},
    );
  }
}