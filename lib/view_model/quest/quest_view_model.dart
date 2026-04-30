import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/quest/feeling_model.dart';
import 'package:frontend/models/quest/today_mission_model.dart';
import 'package:frontend/models/quest/weekly_stats_model.dart'; // 주간 통계 모델 추가 필요
import '../../repository/quest/quest_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuestViewModel extends ChangeNotifier {
  final QuestRepository _repository = QuestRepository();

  int _currentStep = 0;
  bool _isLoading = false;
  String _message = "오늘의 기분은 어때?";
  FeelingModel? _feelingData;
  List<TodayMissionModel> _todayMissions = [];
  WeeklyStatsModel? _weeklyStats;

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String get message => _message;
  FeelingModel? get feelingData => _feelingData;
  List<TodayMissionModel> get todayMissions => _todayMissions;

  WeeklyStatsModel? get weeklyStats => _weeklyStats;

  void changeStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // 현재 테스트 중인 토큰
  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  // 토큰의 Payload에서 'sub' 값을 추출하는 함수
  int _getChildIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;

      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final String decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);

      return int.parse(json['sub'].toString());
    } catch (e) {
      print("토큰 디코딩 에러: $e");
      return 1;
    }
  }

  // 오늘 감정 조회
  Future<void> loadTodayMood() async {
    _isLoading = true;
    _message = "가져오는 중...";
    notifyListeners();

    final int dynamicChildId = _getChildIdFromToken(_testToken);
    _feelingData = await _repository.getTodayMood(dynamicChildId, _testToken);

    if (_feelingData != null) {
      if (_feelingData!.primaryEmotion == "NONE" ||
          _feelingData!.primaryEmotion == "기록 없음") {
        _message = "오늘의 기분은 어때?";
      } else {
        _message = "오늘은 ${_feelingData!.primaryEmotion}!";
      }
    } else {
      _message = "서버 연결에 실패했어요.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // 감정 기록 저장 조회
  Future<void> saveFeeling(String selectedEmotion) async {
    _isLoading = true;
    notifyListeners();

    final int dynamicChildId = _getChildIdFromToken(_testToken);
    final bool isSuccess = await _repository.registerTodayMood(
        _testToken, dynamicChildId, selectedEmotion);

    if (isSuccess) {
      await loadTodayMood();
    } else {
      _message = "기분 저장에 실패했어요.";
      _isLoading = false;
      notifyListeners();
    }
  }

  // 오늘의 미션 목록 조회
  Future<void> fetchTodayMissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final int dynamicChildId = _getChildIdFromToken(_testToken);
      print("[ViewModel] 미션 목록 로드 시작 (childId: $dynamicChildId)");

      final List<TodayMissionModel> missions =
      await _repository.getTodayMissions(dynamicChildId, _testToken);

      _todayMissions = missions;
    } catch (e) {
      print("[ViewModel 에러] 미션 로드 실패: $e");
      _todayMissions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 주간 달성률 조회 (퀘스트)
  Future<void> fetchWeeklyStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final int dynamicChildId = _getChildIdFromToken(_testToken);
      print("[ViewModel] 주간 통계 로드 시작 (childId: $dynamicChildId)");

      // Repository에 getWeeklyStats 메서드를 구현해야 함
      final WeeklyStatsModel? stats = await _repository.getWeeklyStats(dynamicChildId, _testToken);

      if (stats != null) {
        _weeklyStats = stats;
        print("[ViewModel] 주간 통계 로드 완료: ${stats.weeklySuccessRate}%");
      }
    } catch (e) {
      print("[ViewModel 에러] 주간 통계 로드 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}