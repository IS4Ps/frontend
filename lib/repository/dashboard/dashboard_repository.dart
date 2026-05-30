import 'dart:convert';
import 'package:frontend/models/dashboard/monthly_mood_model.dart'; // 모델 경로에 맞춰 수정
import '../../models/dashboard/minigame_log_response_model.dart';
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
        final response = await _apiService.fetchMonthlyStats(
            childId, token, date.year, date.month);
        if (response.statusCode == 200) {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          final dailyList = body['data']['dailyList'] as List;
          print("[히트맵] ${date.month}월 데이터 개수: ${dailyList.length}"); // 추가
          for (final day in dailyList) {
            final rate = (day['completionRate'] as num).toDouble();
            if (rate == 0)
              result.add(0);
            else if (rate <= 33)
              result.add(1);
            else if (rate <= 66)
              result.add(2);
            else
              result.add(3);
          }
        }
      } catch (e) {
        print("[Repository 에러] getRoutineHeatmapData: $e");
      }
    }
    return result;
  }

  // 미니게임 기록 조회
  Future<List<MinigameLogResponseModel>> getMinigameLogs(int childId, String gameType, String token) async {
    try {
      print("[Dashboard Repository] 미니게임 기록 조회 시작 (childId: $childId, gameType: $gameType)");

      final response = await _apiService.fetchMinigameLogs(childId, gameType, token);

      print("[Dashboard Repository] 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("[Dashboard API 성공] $gameType 기록 로드 완료");

        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];

          // JSON 배열을 MinigameLogResponseModel 객체 리스트로 깔끔하게 변환하여 반환
          return dataList.map((json) => MinigameLogResponseModel.fromJson(json)).toList();
        } else {
          print("[Dashboard 데이터 분석] 응답은 성공했으나 'data' 필드가 비어있거나 배열이 아닙니다.");
          return [];
        }
      } else {
        print("[Dashboard API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.body}");
        return [];
      }
    } catch (e, stacktrace) {
      // 디버깅을 원활하게 하기 위해 예외 내용과 스택트레이스를 상세히 출력
      print("[Dashboard Repository 에러] getMinigameLogs 상세 예외: $e");
      print("[Dashboard Repository 스택트레이스] $stacktrace");
      return [];
    }

  }
}