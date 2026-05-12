import 'package:dio/dio.dart';
import '../../services/setting/setting_api_service.dart';
import 'package:frontend/models/setting/parent_model.dart';

class SettingRepository {
  final SettingApiService _apiService = SettingApiService();

  // 내 정보 조회
  Future<ParentModel?> getParentInfo() async {
    try {
      print("[API 호출] 내 정보 조회 시작");

      final response = await _apiService.fetchParentInfo();

      if (response.statusCode == 200) {
        print("[API 성공] 상태 코드: ${response.statusCode}");

        final body = response.data;

        if (body['success'] == true && body['data'] != null) {
          return ParentModel.fromJson(body['data']);
        } else {
          print("[데이터 분석] 응답은 성공했으나 'data' 필드가 비어있습니다.");
          return null;
        }
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.data}");
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print("[Repository 에러] DioException: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("[Repository 에러] 내 정보 로드 중 문제 발생: $e");
      }
      return null;
    }
  }
}