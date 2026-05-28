import 'dart:convert';
import 'package:frontend/models/dashboard/monthly_mood_model.dart'; // 모델 경로에 맞춰 수정
import '../../services/dashboard/dashboard_api_service.dart'; // 서비스 경로에 맞춰 수정

class DashboardRepository {
  final DashboardApiService _apiService = DashboardApiService();

  // 월간 감정 캘린더 조회
  Future<MonthlyMoodModel?> getMonthlyMood(int childId, String token, int year, int month) async {
    try {
      print("[Dashboard API 호출] 월간 감정 조회 시작 (childId: $childId, $year년 $month월)");

      final response = await _apiService.fetchMonthlyMood(childId, token, year, month);

      if (response.statusCode == 200) {
        print("[Dashboard API 성공] 월간 데이터 로드 완료");

        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['data'] != null) {
          // MonthlyMoodModel.fromJson을 호출하여 데이터 변환
          return MonthlyMoodModel.fromJson(body);
        } else {
          print("[Dashboard 데이터 분석] 응답은 성공했으나 'data' 필드가 비어있습니다.");
          return null;
        }
      } else {
        print("[Dashboard API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.body}");
        return null;
      }
    } catch (e) {
      print("[Dashboard Repository 에러] 월간 감정 로드 중 문제 발생: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeeklyStats(int childId) async {
    try {
      print("[API 호출] 주간 성공률 조회 시작 (childId: $childId)");

      final response = await _apiService.fetchWeeklyStats(childId);

      if (response.statusCode == 200) {
        print("[API 성공] 주간 성공률 조회 완료");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("[Repository 에러] 주간 성공률 로드 중 문제 발생: $e");
      return null;
    }
  }

  Future<List<int>> getRoutineHeatmapData(int childId, String token) async {
    final now = DateTime.now();
    List<int> result = [];

    for (int i = 2; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      try {
        final response = await _apiService.fetchMonthlyStats(childId, token, date.year, date.month);
        if (response.statusCode == 200) {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          final dailyList = body['data']['dailyList'] as List;
          print("[히트맵] ${date.month}월 데이터 개수: ${dailyList.length}");  // 추가
          for (final day in dailyList) {
            final rate = (day['completionRate'] as num).toDouble();
            if (rate == 0) result.add(0);
            else if (rate <= 33) result.add(1);
            else if (rate <= 66) result.add(2);
            else result.add(3);
          }
        }
      } catch (e) {
        print("[Repository 에러] getRoutineHeatmapData: $e");
      }
    }
    return result;
  }
}