import 'package:dio/dio.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_profile_response_model.dart';
import '../../services/profile/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  // 아이 프로필 생성
  Future<ChildProfileResponseModel?> createChildProfile(ChildProfileRequestModel requestModel) async {
    try {
      final response = await _apiService.postChildProfile(requestModel.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = response.data;
        print("[API 응답 원문]: $data");

        // Dio는 이미 JSON을 Map으로 변환해서 주거나 String으로 줌
        if (data is String) {
          final RegExp regExp = RegExp(r'\d+');
          final match = regExp.firstMatch(data);
          int? extractedId = match != null ? int.parse(match.group(0)!) : null;

          return ChildProfileResponseModel(
            success: true,
            code: response.statusCode ?? 200,
            message: data,
            childId: extractedId,
          );
        }

        // 응답이 Map인 경우
        return ChildProfileResponseModel.fromJson(data);
      } else {
        return ChildProfileResponseModel(success: false, code: response.statusCode ?? 500, message: "서버 오류");
      }
    } catch (e) {
      if (e is DioException) {
        print("[Repository 에러] DioException: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("[Repository 에러] 상세: $e");
      }
      return null;
    }
  }
}