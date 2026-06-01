import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/profile/child_job_reqeust_model.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_profile_response_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../models/profile/job_list_response_model.dart';
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
  Future<Map<String, dynamic>?> registerChildByQr(String linkToken, String deviceId) async {
    try {
      debugPrint('🚀 [Repository] 최종 연동 시도 - linkToken: $linkToken, deviceId: $deviceId');

      final response = await _apiService.registerChildByQr(linkToken, deviceId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
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
  Future<ChildInformationResponseModel?> getChildInformation(String childId, String token) async {
    try {
      debugPrint('🚀 [Repository] 정보 조회 시도 - ID: $childId');

      final response = await _apiService.getChildInfo(childId, token);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 아이 정보 조회 성공");
        debugPrint("[Repository] 응답 데이터: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);
        return ChildInformationResponseModel.fromJson(body);
      } else {
        debugPrint("[Repository] 정보 조회 권한 없음 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository 정보 조회 에러]: $e");
      return null;
    }
  }

  // --- [5. 아이 기기 자동 로그인] ---
  Future<Map<String, dynamic>?> loginAsChildAuto(String deviceId) async {
    try {
      final response = await _apiService.loginAsChildAuto(deviceId);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 자동 로그인 성공 응답: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);

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

  // --- [6. 🚀 추가: 직업 목록 조회] (인증 불필요) ---
  Future<List<JobModel>?> fetchJobList() async {
    try {
      final response = await _apiService.getJobList();

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 직업 목록 조회 결과: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);

        // JobListResponseModel을 거쳐 내부의 data(List<JobModel>)만 쏙 빼서 리턴
        final responseModel = JobListResponseModel.fromJson(body);
        return responseModel.data;
      } else {
        debugPrint("[Repository] 직업 목록 조회 실패 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository 직업 목록 조회 에러]: $e");
      return null;
    }
  }

  // --- [7. 아이 캐릭터 직업 선택/변경] (부모 권한) ---
  Future<JobListResponseModel?> selectChildJob(String childId, int jobId, String parentToken) async {
    try {
      final requestModel = ChildJobRequestModel(jobId: jobId);

      // ApiService로 모델을 전달합니다.
      final response = await _apiService.patchChildJob(childId, requestModel, parentToken);

      if (response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        debugPrint("[Repository] 직업 선택 성공 응답: $originalBody");

        final Map<String, dynamic> body = jsonDecode(originalBody);

        // 🚀 정확하게 JobListResponseModel로 파싱하여 반환합니다.
        return JobListResponseModel.fromJson(body);
      } else {
        debugPrint("[Repository] 직업 선택 실패 (상태코드: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint("[Repository] 직업 선택 에러: $e");
      return null;
    }
  }
}