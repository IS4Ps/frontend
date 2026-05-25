import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_profile_response_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../services/profile/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  // --- [1. 아이 프로필 생성] (부모 앱 전용) ---
  Future<ChildProfileResponseModel?> createChildProfile(ChildProfileRequestModel requestModel) async {
    try {
      final response = await _apiService.postChildProfile(requestModel.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 프로필 생성 응답: $originalBody");

        // 응답이 JSON 형식이 아닐 경우(텍스트 포함 ID만 올 경우)를 대비한 파싱
        if (!originalBody.trim().startsWith('{')) {
          final RegExp regExp = RegExp(r'\d+');
          final match = regExp.firstMatch(originalBody);
          int? extractedId = match != null ? int.parse(match.group(0)!) : null;

          return ChildProfileResponseModel(
            success: true,
            code: response.statusCode,
            message: originalBody,
            childId: extractedId,
          );
        }

        final body = jsonDecode(originalBody);
        return ChildProfileResponseModel.fromJson(body);
      } else {
        return ChildProfileResponseModel(
            success: false,
            code: response.statusCode,
            message: "서버 오류: ${response.statusCode}"
        );
      }
    } catch (e) {
      debugPrint("[Repository 생성 에러]: $e");
      return null;
    }
  }

  // --- [2. QR 연동용 링크 토큰 발급] (부모 앱 전용) ---
  Future<String?> getLinkToken(int childId) async {
    try {
      final response = await _apiService.getLinkToken(childId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'] as String?;
      } else {
        debugPrint('❌ [링크 토큰 발급 실패] 상태코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [Repository getLinkToken 에러]: $e');
      return null;
    }
  }

  // --- [3. QR 스캔 후 최종 기기 등록 및 로그인] (아이 앱 전용) ---
  // ✅ 403 에러 방지를 위해 아이 전용 토큰을 반환받는 핵심 API
  Future<Map<String, dynamic>?> registerChildByQr(String linkToken, String deviceId) async {
    try {
      debugPrint('🚀 [Repository] 최종 연동 시도 - linkToken: $linkToken, deviceId: $deviceId');

      final response = await _apiService.registerChildByQr(linkToken, deviceId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // 성공 시 데이터 안의 { accessToken, childId, nickname } 맵 반환
        return body['data'];
      } else {
        debugPrint('❌ 최종 연동 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Repository 연동 에러: $e');
      return null;
    }
  }

  // --- [4. 아이 정보 상세 조회] (공통) ---
  // ✅ childId 타입을 String으로 변경하여 UUID(cc5e3eb0...) 파싱 에러 방지
  Future<ChildInformationResponseModel?> getChildInformation(String childId, String token) async {
    try {
      debugPrint('🚀 [Repository] 정보 조회 시도 - ID: $childId');

      final response = await _apiService.getChildInfo(childId, token);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 아이 정보 조회 성공");

        final Map<String, dynamic> body = jsonDecode(originalBody);
        return ChildInformationResponseModel.fromJson(body);
      } else {
        // 403 에러 발생 시 로그 출력
        debugPrint("[Repository] 정보 조회 권한 없음 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository 정보 조회 에러]: $e");
      return null;
    }
  }

  // 아이 기기 자동 로그인
  Future<Map<String, dynamic>?> loginAsChildAuto(String deviceId) async {
    try {
      final response = await _apiService.loginAsChildAuto(deviceId);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 자동 로그인 성공 응답: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);

        // 명세서 구조상 "data"안에 "accessToken"이 있으므로 data 맵을 리턴
        if (body['data'] != null) {
          return body['data'] as Map<String, dynamic>;
        }
        return body;
      } else {
        debugPrint("[Repository] 자동 로그인 실패 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository 자동 로그인 에러]: $e");
      return null;
    }
  }
}