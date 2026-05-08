import 'dart:convert';
import '../../services/routine/mission_api_service.dart';

class MissionRepository {
  final MissionApiService _apiService = MissionApiService();

  Future<bool> createMission(Map<String, dynamic> body) async {
    try {
      print("[API 호출] 미션 생성 시작");

      final response = await _apiService.createMission(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[API 성공] 미션 생성 완료");
        print("[응답 데이터] ${response.body}");
        return true;
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}");
        print("[에러 내용] ${response.body}");
        return false;
      }
    } catch (e) {
      print("[Repository 에러] 네트워크/런타임 문제 발생: $e");
      return false;
    }
  }
}