import 'dart:convert';
import '../../services/setting/setting_api_service.dart'; // SettingApiService 경로에 맞춰 수정하세요
import 'package:frontend/models/setting/parent_model.dart';

class SettingRepository {
  final SettingApiService _apiService = SettingApiService();

  // 내 정보(부모 프로필) 조회
  Future<ParentModel?> getParentInfo(String token) async {
    try {
      print("[API 호출] 내 정보 조회 시작");

      final response = await _apiService.fetchParentInfo(token);

      if (response.statusCode == 200) {
        print("[API 성공] 상태 코드: ${response.statusCode}");

        // 한글 깨짐 방지 디코딩
        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['success'] == true && body['data'] != null) {
          // JSON 데이터를 ParentModel 객체로 변환
          return ParentModel.fromJson(body['data']);
        } else {
          print("[데이터 분석] 응답은 성공했으나 'data' 필드가 비어있습니다.");
          return null;
        }
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.body}");
        return null;
      }
    } catch (e) {
      print("[Repository 에러] 내 정보 로드 중 문제 발생: $e");
      return null;
    }
  }
}