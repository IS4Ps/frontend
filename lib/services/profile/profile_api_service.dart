import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
// ✅ TokenManager를 직접 참조하여 최신 토큰을 가져옵니다.
import 'package:frontend/auth/token_manager.dart';

import '../../models/profile/child_job_reqeust_model.dart';

class ProfileApiService {
  static const String baseUrl = "http://100.27.204.252:8080";

  // 1. [부모 권한] 아이 프로필 생성
  Future<http.Response> postChildProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/children');
    // ✅ 부모 토큰 사용
    final String? token = TokenManager().parentToken;

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  // 2. [부모 권한] 연동용 링크 토큰 발급
  Future<http.Response> getLinkToken(int childId) async {
    final url = Uri.parse('$baseUrl/children/$childId/link-token');
    // ✅ 부모 토큰 사용
    final String? token = TokenManager().parentToken;

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // --- [중략: linkChildDevice 등은 명세에 따라 유지] ---

  // 3. ✅ [아이 권한] QR 스캔을 통한 최종 연동 및 로그인
  Future<http.Response> registerChildByQr(String linkToken, String deviceId) async {
    final url = Uri.parse('$baseUrl/auth/child/register-by-qr')
        .replace(queryParameters: {
      'linkToken': linkToken,
      'deviceId': deviceId,
    });

    return await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        // 기기 등록 시점에는 아직 토큰이 없으므로 비워둠 (명세서 기준)
      },
    );
  }

  // 4. 🔥 [공통/아이 권한] 아이 정보 상세 조회 (403 해결 지점)
  Future<http.Response> getChildInfo(String childId, String? token) async {
    final url = Uri.parse('$baseUrl/children/$childId');

    // ✅ 핵심: 매개변수로 받은 token보다 TokenManager의 최신 토큰을 우선시합니다.
    // 연동 직후라면 TokenManager().childToken에 '아이 토큰'이 들어있을 것입니다.
    final String? activeToken = TokenManager().parentToken ?? token;

    debugPrint('📡 [API Call] getChildInfo 호출 - 사용 토큰: ${activeToken?.substring(0, 15)}...');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $activeToken',
      },
    );
  }

  // 아이 기기 자동 로그인 (이미 연동된 기기)
  Future<http.Response> loginAsChildAuto(String deviceId) async {
    final url = Uri.parse('$baseUrl/auth/child/login');

    final bodyData = jsonEncode({
      "deviceId": deviceId, // 오직 기기 고유 ID만 전송
    });

    debugPrint('🚀 [자동 로그인 요청] 전송 데이터: $bodyData');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: bodyData,
    );
  }

  // 직업 선택
  // 직업 선택 (상세 로그 버전)
  Future<http.Response> patchChildJob(
      String childId,
      ChildJobRequestModel requestModel,
      String parentToken,
      ) async {
    final url = Uri.parse('$baseUrl/children/$childId/job');
    final bodyString = jsonEncode(requestModel.toJson());

    // 🔍 보낼 데이터 미리 콘솔에 찍기
    debugPrint('================ [JOB PATCH REQUEST] ================');
    debugPrint('🚀 URL: $url');
    debugPrint('🔑 Token: Bearer ${parentToken.length > 15 ? parentToken.substring(0, 15) : parentToken}...');
    debugPrint('📦 Body: $bodyString');
    debugPrint('=====================================================');

    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $parentToken',
      },
      body: bodyString,
    );
  }

  // 직업 목록 조회
  Future<http.Response> getJobList() async {
    // 명세서 상의 주소: /api/jobs
    final url = Uri.parse('$baseUrl/api/jobs');

    debugPrint('📡 [API Call] getJobList 호출 - 모든 직업 목록 요청');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  // 월간 stats 조회
  Future<http.Response> getMonthlyStats(String childId, String token, int year, int month) async {
    final url = Uri.parse('$baseUrl/api/v1/missions/stats/$childId/monthly?year=$year&month=$month');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}