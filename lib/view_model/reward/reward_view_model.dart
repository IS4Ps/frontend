import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 추가
import 'package:frontend/auth/token_manager.dart'; // ✅ 추가
import 'package:frontend/models/reward/offline_reward_list_model.dart';
import 'package:frontend/models/reward/offline_reward_request_model.dart';
import '../../repository/reward/reward_repository.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardRepository _repository = RewardRepository();

  bool _isLoading = false;
  bool _isWeekly = true;
  List<OfflineRewardListModel> _allOfflineRewards = [];
  List<OfflineRewardListModel> _editingRewards = [];

  bool get isLoading => _isLoading;
  bool get isWeekly => _isWeekly;
  List<OfflineRewardListModel> get editingRewards => _editingRewards;

  // --- ✅ [핵심] 실제 데이터 소스 통합 로직 ---

  /// SharedPreferences에서 현재 선택된 자녀 ID 가져오기
  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    // SettingScreen에서 아이 등록/선택 시 저장한 'selectedChildId'를 사용합니다.
    String? savedId = prefs.getString('selectedChildId');

    if (savedId != null && savedId != "null") {
      return int.parse(savedId);
    }

    // ID가 없을 경우 에러를 던져서 fetch 로직이 중단되게 합니다.
    throw Exception("선택된 자녀가 없습니다.");
  }

  /// TokenManager에서 부모 토큰 가져오기
  String _getAccessToken() {
    // 보상 설정은 부모의 권한이므로 parentToken을 명시적으로 사용하거나
    // 상황에 맞는 활성 토큰을 가져옵니다.
    return TokenManager().parentToken ?? TokenManager().token ?? "";
  }

  // --- ✅ [기존 UI 로직 유지] ---

  void togglePeriod(bool isWeekly) {
    _isWeekly = isWeekly;
    _updateEditingList();
    notifyListeners();
  }

  void _updateEditingList() {
    String type = _isWeekly ? "WEEKLY" : "MONTHLY";
    List<OfflineRewardListModel> filtered =
    _allOfflineRewards.where((r) => r.periodType == type).toList();

    _editingRewards = List.from(filtered);
    _editingRewards.insert(
      0,
      OfflineRewardListModel(
        rewardId: 0,
        periodType: type,
        targetDays: 0,
        rewardPromiseText: "",
        status: "PENDING",
      ),
    );
  }

  void addRewardStep() {
    _editingRewards.add(
      OfflineRewardListModel(
        rewardId: 0,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetDays: 0,
        rewardPromiseText: "",
        status: "PENDING",
      ),
    );
    notifyListeners();
  }

  void removeRewardStep(int index) {
    if (_editingRewards.length > 1) {
      _editingRewards.removeAt(index);
    } else {
      _editingRewards[0] = OfflineRewardListModel(
        rewardId: 0,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetDays: 0,
        rewardPromiseText: "",
        status: "PENDING",
      );
    }
    notifyListeners();
  }

  void updateRewardEntry(int index, {int? targetDays, String? text}) {
    if (index >= 0 && index < _editingRewards.length) {
      final current = _editingRewards[index];
      _editingRewards[index] = OfflineRewardListModel(
        rewardId: current.rewardId,
        periodType: current.periodType,
        targetDays: targetDays ?? current.targetDays,
        rewardPromiseText: text ?? current.rewardPromiseText,
        status: current.status,
      );
    }
  }

  // --- ✅ [API 호출 로직 수정] ---

  // 보상 목록 조회
  Future<void> fetchOfflineRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ 하드코딩된 토큰 대신 실제 ID와 토큰 사용
      final int childId = await _getChildId();
      final String token = _getAccessToken();

      debugPrint("[RewardViewModel] 보상 목록 로드 시작 (childId: $childId)");

      final List<OfflineRewardListModel> rewards =
      await _repository.getOfflineRewards(childId, token);

      _allOfflineRewards = rewards;
      _updateEditingList();
    } catch (e) {
      debugPrint("[RewardViewModel 에러] 로드 실패: $e");
      _allOfflineRewards = [];
      _updateEditingList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 보상 등록
  Future<void> saveRewardStep(int index) async {
    if (index < 0 || index >= _editingRewards.length) return;

    final reward = _editingRewards[index];

    if (reward.rewardPromiseText.isEmpty || reward.targetDays <= 0) {
      debugPrint("[RewardViewModel] 입력값이 올바르지 않습니다.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();

      final request = OfflineRewardRequestModel(
        childId: childId,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetDays: reward.targetDays,
        rewardPromiseText: reward.rewardPromiseText,
      );

      debugPrint("[RewardViewModel] 보상 등록 시도 (childId: $childId)");

      final bool isSuccess = await _repository.registerOfflineReward(token, request);

      if (isSuccess) {
        debugPrint("[RewardViewModel] 보상 등록 성공");
        await fetchOfflineRewards();
      }
    } catch (e) {
      debugPrint("[RewardViewModel 에러] 등록 중 오류 발생: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}