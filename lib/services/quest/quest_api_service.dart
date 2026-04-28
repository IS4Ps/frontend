import 'dart:convert'; // jsonEncode를 위해 추가
import 'package:http/http.dart' as http;
import 'package:frontend/models/quest/feeling_request_model.dart'; // import 확인!

class QuestApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  // 오늘 감정 조회
  Future<http.Response> fetchTodayMood(int childId, String token) async {
    final url = Uri.parse('$baseUrl/api/v1/mood-logs/$childId/today');
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // 감정 기록 저장
  Future<http.Response> postTodayMood(String token, FeelingRequestModel request) async {
    final url = Uri.parse('$baseUrl/api/v1/mood-logs'); // Swagger 엔드포인트 확인
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()), // 모델을 JSON 문자열로 변환
    );
  }

  // 오늘의 미션 목록 조회
  Future<http.Response> fetchTodayMissions(int childId, String token) async {
    final url = Uri.parse('$baseUrl/api/v1/missions/today/$childId');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}