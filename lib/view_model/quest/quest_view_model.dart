import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth; // 프로젝트 경로 확인 필수
import '../../repository/quest/quest_repository.dart';

// 모델 임포트
import 'package:frontend/models/quest/feeling_model.dart';
import 'package:frontend/models/quest/today_mission_model.dart';
import 'package:frontend/models/quest/weekly_stats_model.dart';
import 'package:frontend/models/quest/equipped_item_model.dart';
import 'package:frontend/models/quest/n_back_start_request_model.dart';
import 'package:frontend/models/quest/n_back_start_response_model.dart';
import 'package:frontend/models/quest/n_back_submit_response_model.dart';
import 'package:frontend/models/quest/n_back_submit_request_model.dart';
import 'package:frontend/models/quest/go_nogo_start_request_model.dart';
import 'package:frontend/models/quest/go_nogo_start_response_model.dart';
import 'package:frontend/models/quest/go_nogo_submit_request_model.dart';
import 'package:frontend/models/quest/go_nogo_submit_response_model.dart';
import 'package:frontend/models/quest/stroop_start_request_model.dart';
import 'package:frontend/models/quest/stroop_start_response_model.dart';
import 'package:frontend/models/quest/stroop_submit_request_model.dart';
import 'package:frontend/models/quest/stroop_submit_response_model.dart';

class QuestViewModel extends ChangeNotifier {
  final QuestRepository _repository = QuestRepository();

  int _currentStep = 0;
  bool _isLoading = false;
  String _message = "오늘의 기분은 어때?";

  FeelingModel? _feelingData;
  List<TodayMissionModel> _todayMissions = [];
  WeeklyStatsModel? _weeklyStats;
  List<EquippedItemModel> _equippedItems = [];

  // 게임 세션 및 결과 데이터 저장 변수
  NBackStartResponseModel? _nBackData;
  NBackSubmitResponseModel? _nBackResult;

  GoNoGoStartResponseModel? _goNoGoData;
  GoNoGoSubmitResponseModel? _goNoGoResult; // [해결] 에러 발생했던 변수

  StroopStartResponseModel? _stroopData;
  StroopSubmitResponseModel? _stroopResult;

  // 기본 정보 Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String get message => _message;
  FeelingModel? get feelingData => _feelingData;
  List<TodayMissionModel> get todayMissions => _todayMissions;
  WeeklyStatsModel? get weeklyStats => _weeklyStats;
  List<EquippedItemModel> get equippedItems => _equippedItems;

  // 게임 관련 Getters (UI에서 이 이름을 사용합니다)
  NBackStartResponseModel? get nBackData => _nBackData;
  NBackSubmitResponseModel? get nBackResult => _nBackResult;

  GoNoGoStartResponseModel? get goNoGoData => _goNoGoData;
  GoNoGoSubmitResponseModel? get goNoGoResult => _goNoGoResult; // [해결] Getter 정의

  StroopStartResponseModel? get stroopData => _stroopData;
  StroopSubmitResponseModel? get stroopResult => _stroopResult;

  void changeStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // --- [Helper] 실제 기기 저장 데이터 및 토큰 추출 로직 ---

  /// SharedPreferences에서 저장된 Child ID 가져오기
  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("연동된 자녀 ID가 없습니다. QR 연동을 확인해주세요.");
  }

  /// TokenManager에서 실제 발급된 토큰 가져오기
  String _getAccessToken() {
    return my_auth.TokenManager().token ?? "";
  }

  // --- [1. 정보 조회 API 관련] ---

  Future<void> loadTodayMood() async {
    _isLoading = true;
    _message = "기분 정보를 가져오는 중...";
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      _feelingData = await _repository.getTodayMood(childId, token);
      if (_feelingData != null) {
        _message = (_feelingData!.primaryEmotion == "NONE" || _feelingData!.primaryEmotion == "기록 없음")
            ? "오늘의 기분은 어때?"
            : "오늘은 ${_feelingData!.primaryEmotion}!";
      }
    } catch (e) {
      debugPrint("Mood Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayMissions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      debugPrint("[API] 미션 로드 시작 (ChildID: $childId)");
      _todayMissions = await _repository.getTodayMissions(childId, token);
    } catch (e) {
      debugPrint("Missions Error: $e");
      _todayMissions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeeklyStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      _weeklyStats = await _repository.getWeeklyStats(childId, token);
    } catch (e) {
      debugPrint("Weekly Stats Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- [2. Go/No-Go 게임 관련] ---

  Future<void> startGoNoGoGame({int difficulty = 1, int totalCount = 20}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = GoNoGoStartRequestModel(childId: childId, totalCount: totalCount, difficulty: difficulty);
      _goNoGoData = await _repository.startGoNoGoGame(token, request);
    } catch (e) {
      debugPrint("GoNoGo Start Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitGoNoGoGame(List<GoNoGoAnswerModel> userAnswers) async {
    if (_goNoGoData == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = GoNoGoSubmitRequestModel(childId: childId, sessionId: _goNoGoData!.sessionId, answers: userAnswers);
      final response = await _repository.submitGoNoGoGame(token, request);
      if (response != null) {
        _goNoGoResult = response; // 결과 저장
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("GoNoGo Submit Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- [3. N-Back 게임 관련] ---

  Future<void> startNBackGame(int nLevel) async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = NBackStartRequestModel(childId: childId, nLevel: nLevel, totalCount: 20);
      _nBackData = await _repository.startNBackGame(token, request);
    } catch (e) {
      debugPrint("N-Back Start Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitNBackGame(List<NBackAnswerModel> userAnswers) async {
    if (_nBackData == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = NBackSubmitRequestModel(childId: childId, sessionId: _nBackData!.sessionId, answers: userAnswers);
      final response = await _repository.submitNBackGame(token, request);
      if (response != null) {
        _nBackResult = response;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("N-Back Submit Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- [4. Stroop 게임 관련] ---

  Future<void> startStroopGame({int totalCount = 20, int difficulty = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = StroopStartRequestModel(childId: childId, totalCount: totalCount, difficulty: difficulty);
      _stroopData = await _repository.startStroopGame(token, request);
    } catch (e) {
      debugPrint("Stroop Start Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitStroopGame(List<StroopAnswerModel> userAnswers) async {
    if (_stroopData == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final request = StroopSubmitRequestModel(childId: childId, sessionId: _stroopData!.sessionId, answers: userAnswers);
      final response = await _repository.submitStroopGame(token, request);
      if (response != null) {
        _stroopResult = response;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Stroop Submit Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 감정 저장
  Future<void> saveFeeling(String selectedEmotion) async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final bool isSuccess = await _repository.registerTodayMood(token, childId, selectedEmotion);
      if (isSuccess) await loadTodayMood();
    } catch (e) {
      debugPrint("Save Feeling Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장착 아이템 조회
  Future<void> fetchEquippedItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();
      final List<EquippedItemModel> items = await _repository.getEquippedItems(childId, token);
      _equippedItems = items.where((item) => item.isEquipped).toList();
    } catch (e) {
      debugPrint("Equipped Items Error: $e");
      _equippedItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}