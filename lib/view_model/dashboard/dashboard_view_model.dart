import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ 카카오 SDK와 이름 충돌 방지를 위해 별칭 추가
import 'package:frontend/auth/token_manager.dart' as my_auth;
import 'package:frontend/models/dashboard/monthly_mood_model.dart';
import '../../repository/dashboard/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  bool _isLoading = false;
  MonthlyMoodModel? _monthlyMoodData;
  String _errorMessage = "";
  Map<String, dynamic>? _weeklyStats;

  // Getter들
  bool get isLoading => _isLoading;
  MonthlyMoodModel? get monthlyMoodData => _monthlyMoodData;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get weeklyStats => _weeklyStats;

  // 주간 완료율 계산
  double get avgCompletionRate => (_weeklyStats?['avgCompletionRate'] ?? 0.0).toDouble();

  // --- ✅ [핵심] 데이터 소스 통합 로직 ---

  /// SharedPreferences에서 현재 선택된 자녀 ID 가져오기
  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');

    debugPrint('🔍 [DashboardViewModel] SharedPreferences ID 체크: $savedId');

    if (savedId != null && savedId != "null" && savedId.isNotEmpty) {
      return int.parse(savedId);
    }

    throw Exception("선택된 자녀 ID가 없습니다.");
  }

  /// ✅ 별칭(my_auth)을 사용하여 우리쪽 TokenManager 호출
  String _getAccessToken() {
    final manager = my_auth.TokenManager();
    return manager.token ?? "";
  }

  // --- ✅ [API 호출 로직] ---

  // 월간 감정 캘린더 조회
  Future<void> fetchMonthlyMood({int? year, int? month}) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();

      final now = DateTime.now();
      final int targetYear = year ?? now.year;
      final int targetMonth = month ?? now.month;

      debugPrint("[DashboardViewModel] 월간 감정 로드 시작 (childId: $childId, year: $targetYear, month: $targetMonth)");

      final MonthlyMoodModel? data = await _repository.getMonthlyMood(
          childId,
          token,
          targetYear,
          targetMonth
      );

      if (data != null) {
        _monthlyMoodData = data;
        debugPrint("[Dashboard API 성공] 기록 발견: ${data.totalCount}개");
        data.moodMap.forEach((date, log) {
          debugPrint("[감정 로그] $date: ${log.primaryEmotion}, score: ${log.score}");
        });
      } else {
        _errorMessage = "데이터를 불러오지 못했습니다.";
      }
    } catch (e) {
      debugPrint("[DashboardViewModel 에러] $e");
      _errorMessage = "자녀 정보를 불러오는 중 오류가 발생했습니다.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 주간 통계 조회
  Future<void> fetchWeeklyStats() async {
    try {
      final int childId = await _getChildId();
      debugPrint("[DashboardViewModel] 주간 통계 로드 시작 (childId: $childId)");

      final data = await _repository.getWeeklyStats(childId);
      if (data != null) {
        _weeklyStats = data;
        debugPrint("[DashboardViewModel] 주간 통계 로드 완료: ${data['avgCompletionRate']}%");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("[DashboardViewModel 통계 에러] $e");
    }
  }

  List<int> _routineHeatmapData = [];
  List<int> get routineHeatmapData => _routineHeatmapData;

  Future<void> fetchRoutineHeatmap() async {
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      _routineHeatmapData = await _repository.getRoutineHeatmapData(childId, token);
      notifyListeners();
    } catch (e) {
      debugPrint("[DashboardViewModel 에러] fetchRoutineHeatmap: $e");
    }
  }

  // 미니게임 결과 조회
  // 미니게임 기록 관련 상태 변수들
  List<dynamic> _nBackLogs = [];
  List<dynamic> _goNoGoLogs = [];
  List<dynamic> _stroopLogs = [];

  List<dynamic> get nBackLogs => _nBackLogs;
  List<dynamic> get goNoGoLogs => _goNoGoLogs;
  List<dynamic> get stroopLogs => _stroopLogs;

  Future<void> fetchAllMinigameLogs() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      // 1. 기존 구현된 안전한 기기 데이터 및 토큰 추출 헬퍼 활용
      final int childId = await _getChildId();
      final String token = _getAccessToken();

      debugPrint("[DashboardViewModel] 미니게임 3종 기록 일괄 로드 시작 (childId: $childId)");

      // 2. 세 개의 API 요청을 비동기 병렬(Future.wait)로 동시에 처리하여 로딩 속도 최적화
      // ※ DashboardRepository에 getMinigameLogs 메서드가 구현되어 있어야 합니다.
      final results = await Future.wait([
        _repository.getMinigameLogs(childId, "N_BACK", token),
        _repository.getMinigameLogs(childId, "GO_NO_GO", token),
        _repository.getMinigameLogs(childId, "STROOP", token),
      ]);

      // 3. 각각의 리스트 결과 담기
      _nBackLogs = results[0];
      _goNoGoLogs = results[1];
      _stroopLogs = results[2];

      debugPrint("[Dashboard API 성공] 미니게임 로그 묶음 로드 완료 "
          "(N-Back: ${_nBackLogs.length}개, GoNoGo: ${_goNoGoLogs.length}개, Stroop: ${_stroopLogs.length}개)");

    } catch (e) {
      debugPrint("[DashboardViewModel 미니게임 로그 에러] $e");
      _errorMessage = "미니게임 점수 기록을 불러오는 중 오류가 발생했습니다.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}