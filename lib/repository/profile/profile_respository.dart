import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_profile_response_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../services/profile/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  // --- [1. 아이 프로필 생성] ---
  Future<ChildProfileResponseModel?> createChildProfile(ChildProfileRequestModel requestModel) async {
    try {
      final response = await _apiService.postChildProfile(requestModel.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 프로필 생성 응답: $originalBody");

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

  // --- [2. 아동 로그인 (토큰 발급)] ---
  Future<Map<String, dynamic>?> loginAsChild(String deviceId, int childId) async {
    try {
      debugPrint('🚀 [Repository] 로그인 시도 - deviceId: $deviceId, childId: $childId');

      // ApiService에 전달 (이미 childId가 int이므로 그대로 전달)
      final response = await _apiService.loginAsChild(deviceId, childId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data']; // accessToken이 담긴 data 객체 반환
      } else {
        debugPrint('❌ [로그인 실패] 상태코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [Repository 로그인 에러]: $e');
      return null;
    }
  }

  // --- [3. 아이 정보 상세 조회] ---
  Future<ChildInformationResponseModel?> getChildInformation(String childId, String token) async {
    try {
      final response = await _apiService.getChildInfo(childId, token);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 아이 정보 조회 결과: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);
        return ChildInformationResponseModel.fromJson(body);
      } else {
        debugPrint("[Repository] 정보 조회 실패 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository 정보 조회 에러]: $e");
      return null;
    }
  }
}