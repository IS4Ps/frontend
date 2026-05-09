import 'package:http/http.dart' as http;

class SettingApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  // 내 정보 조회 (부모 계정)
  Future<http.Response> fetchParentInfo(String token) async {
    final url = Uri.parse('$baseUrl/parents/me');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 부모 토큰 인증
      },
    );
  }
}