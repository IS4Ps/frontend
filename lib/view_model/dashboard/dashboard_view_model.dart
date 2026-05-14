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
}