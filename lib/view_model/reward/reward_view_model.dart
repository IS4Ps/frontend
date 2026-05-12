import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ 'as my_auth' 별칭을 반드시 추가해야 카카오 TokenManager와 안 겹칩니다.
import 'package:frontend/auth/token_manager.dart' as my_auth;
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

  /// ✅ SharedPreferences에서 자녀 ID 가져오기
  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    // SettingScreen에서 저장한 키값 'selectedChildId'를 읽어옵니다.
    String? savedId = prefs.getString('selectedChildId');

    debugPrint('🔍 [RewardViewModel] SharedPreferences ID 체크: $savedId');

    if (savedId != null && savedId != "null" && savedId.isNotEmpty) {
      return int.parse(savedId);
    }

    // 여기서 Exception이 발생하면 로그에 "선택된 자녀가 없습니다."가 찍힙니다.
    throw Exception("선택된 자녀가 없습니다.");
  }

  /// ✅ 별칭(my_auth)을 사용하여 우리쪽 TokenManager 호출
  String _getAccessToken() {
    final manager = my_auth.TokenManager();
    return manager.parentToken ?? manager.token ?? "";
  }

  // --- UI 로직 (기존과 동일) ---

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
    _editingRewards.add(OfflineRewardListModel(
      rewardId: 0,
      periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
      targetDays: 0,
      rewardPromiseText: "",
      status: "PENDING",
    ));
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

  // --- API 통신 로직 ---

  Future<void> fetchOfflineRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final int childId = await _getChildId();
      final String token = _getAccessToken();

      debugPrint("[RewardViewModel] API 호출 시작 (childId: $childId)");

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

  Future<void> saveRewardStep(int index) async {
    if (index < 0 || index >= _editingRewards.length) return;

    final reward = _editingRewards[index];
    if (reward.rewardPromiseText.isEmpty || reward.targetDays <= 0) {
      debugPrint("[RewardViewModel] 유효하지 않은 입력값");
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

      final bool isSuccess = await _repository.registerOfflineReward(token, request);

      if (isSuccess) {
        await fetchOfflineRewards();
      }
    } catch (e) {
      debugPrint("[RewardViewModel 에러] 등록 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}