import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth;

class QuizApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("자녀 ID가 없습니다.");
  }

  String _getAccessToken() {
    return my_auth.TokenManager().token ?? "";
  }

  Future<List<Map<String, dynamic>>> generateQuiz(List<XFile> images) async {
    final int childId = await _getChildId();
    final String token = _getAccessToken();

    final List<Map<String, String>> imageList = [];
    for (final image in images) {
      final bytes = await File(image.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      imageList.add({'imageBase64': base64Str});
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/ai-quizzes/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'childId': childId,
        'category': '일반',
        'images': imageList,
      }),
    );

    print('[API 호출] AI 퀴즈 생성');
    print('[응답 데이터] ${response.body}');

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']['quizzes']);
  }

  Future<Map<String, dynamic>> submitAnswer(int quizId, String answer) async {
    final String token = _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/ai-quizzes/$quizId/answer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'answer': answer}),
    );
    final data = jsonDecode(response.body);
    return data['data'];
  }
}