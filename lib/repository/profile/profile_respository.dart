import 'dart:convert';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_profile_response_model.dart';
import '../../services/profile/profile_api_service.dart'; // API 서비스 경로에 맞게 수정하세요

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  // 아이 프로필 생성
  Future<ChildProfileResponseModel?> createChildProfile(ChildProfileRequestModel requestModel) async {
    try {
      final response = await _apiService.postChildProfile(requestModel.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        String originalBody = utf8.decode(response.bodyBytes);
        print("[API 응답 원문]: $originalBody");

        // 만약 응답이 JSON 형태({로 시작)가 아니라면 수동으로 모델을 생성
        if (!originalBody.trim().startsWith('{')) {
          // 문자열에서 숫자만 추출 (아이 ID: 8 에서 8 추출)
          final RegExp regExp = RegExp(r'\d+');
          final match = regExp.firstMatch(originalBody);
          int? extractedId = match != null ? int.parse(match.group(0)!) : null;

          return ChildProfileResponseModel(
            success: true,
            code: response.statusCode,
            message: originalBody,
            childId: extractedId, // 추출한 ID 삽입
          );
        }

        // 응답이 정상적인 JSON인 경우
        final body = jsonDecode(originalBody);
        return ChildProfileResponseModel.fromJson(body);
      } else {
        // 실패 처리
        return ChildProfileResponseModel(success: false, code: response.statusCode, message: "서버 오류");
      }
    } catch (e) {
      print("[Repository 에러] 상세: $e");
      return null;
    }
  }
}