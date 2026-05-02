import 'dart:convert';
import 'package:http/http.dart' as http;

class RewardApiService {
  // 기존 프로젝트의 베이스 URL 유지
  static const String baseUrl = "http://100.27.204.252:8080";

  // 오프라인 보상 목록 조회
  Future<http.Response> fetchOfflineRewards(int childId, String token) async {
    final url = Uri.parse('$baseUrl/api/v1/offline-rewards/$childId');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // 부모 토큰 인증
        'Content-Type': 'application/json',
      },
    );
  }
}