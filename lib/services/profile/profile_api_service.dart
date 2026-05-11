import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/auth/token_manager.dart' as my_auth;

class ProfileApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  // 아이 로그인 API
  Future<http.Response> loginAsChild(String deviceId, int childId) async {
    final url = Uri.parse('$baseUrl/auth/child/login');

    final bodyData = jsonEncode({
      "deviceId": deviceId, // 여기에 토큰이 들어가지 않도록 체크!
      "childId": childId,
    });

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: bodyData,
    );
  }

  // 아이 프로필 생성
  Future<http.Response> postChildProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/children');
    final String? token = my_auth.TokenManager().token;

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 명세서의 '부모 토큰'
      },
      // Map 데이터를 JSON 문자열로 변환하여 전송
      body: jsonEncode(data),
    );
  }

  // 아이 정보 상세 조회
  Future<http.Response> getChildInfo(String childId, String token) async {
    final url = Uri.parse('$baseUrl/children/$childId');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 명세서의 '부모 토큰'
      },
    );
  }
}