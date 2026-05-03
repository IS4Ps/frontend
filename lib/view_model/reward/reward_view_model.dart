import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/reward/offline_reward_list_model.dart';
import '../../repository/reward/reward_repository.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardRepository _repository = RewardRepository();

  bool _isLoading = false;
  bool _isWeekly = true;
  List<OfflineRewardListModel> _allOfflineRewards = [];

  // 현재 화면에서 편집/입력 중인 보상 단계 리스트
  List<OfflineRewardListModel> _editingRewards = [];

  bool get isLoading => _isLoading;
  bool get isWeekly => _isWeekly;
  List<OfflineRewardListModel> get editingRewards => _editingRewards;

  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  // 탭 전환 함수
  void togglePeriod(bool isWeekly) {
    _isWeekly = isWeekly;
    _updateEditingList();
    notifyListeners();
  }

  // 내부 로직: 서버 데이터 필터링 및 초기 카드 세팅
  void _updateEditingList() {
    String type = _isWeekly ? "WEEKLY" : "MONTHLY";
    List<OfflineRewardListModel> filtered = _allOfflineRewards.where((r) => r.periodType == type).toList();

    if (filtered.isNotEmpty) {
      _editingRewards = List.from(filtered);
    } else {
      // 데이터가 없으면 초기 상태인 빈 카드 1개 세팅
      _editingRewards = [
        OfflineRewardListModel(
            rewardId: 0,
            periodType: type,
            targetPercent: 0,
            rewardPromiseText: "",
            status: "PENDING"
        )
      ];
    }
  }

  // 단계 추가: 리스트에 새 항목 추가
  void addRewardStep() {
    _editingRewards.add(
      OfflineRewardListModel(
        rewardId: 0,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetPercent: 0,
        rewardPromiseText: "",
        status: "PENDING",
      ),
    );
    notifyListeners();
  }

  // 단계 삭제: 특정 인덱스의 항목 제거
  void removeRewardStep(int index) {
    if (_editingRewards.length > 1) {
      _editingRewards.removeAt(index);
    } else {
      // 마지막 남은 카드는 삭제 대신 내용 초기화
      _editingRewards[0] = OfflineRewardListModel(
        rewardId: 0,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetPercent: 0,
        rewardPromiseText: "",
        status: "PENDING",
      );
    }
    notifyListeners();
  }

  // 데이터 업데이트 (입력 시 호출)
  void updateRewardEntry(int index, {int? percent, String? text}) {
    if (index >= 0 && index < _editingRewards.length) {
      final current = _editingRewards[index];
      _editingRewards[index] = OfflineRewardListModel(
        rewardId: current.rewardId,
        periodType: current.periodType,
        targetPercent: percent ?? current.targetPercent,
        rewardPromiseText: text ?? current.rewardPromiseText,
        status: current.status,
      );
    }
  }

  // 토큰에서 childId 추출
  int _getChildIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;
      String payload = parts[1];
      while (payload.length % 4 != 0) payload += '=';
      final String decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);
      return int.parse(json['sub'].toString());
    } catch (e) {
      print("토큰 디코딩 에러: $e");
      return 1;
    }
  }

  // 목록 조회 API 호출
  Future<void> fetchOfflineRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final int dynamicChildId = _getChildIdFromToken(_testToken);
      String currentType = _isWeekly ? "WEEKLY(주간)" : "MONTHLY(월간)";
      print("[ViewModel] 오프라인 보상 목록 로드 시작 (childId: $dynamicChildId, 타입: $currentType)");

      final List<OfflineRewardListModel> rewards =
      await _repository.getOfflineRewards(dynamicChildId, _testToken);

      _allOfflineRewards = rewards;
      _updateEditingList();

      print("[ViewModel] 보상 목록 로드 완료: ${_editingRewards.length}개 ($currentType 기준)");
    } catch (e) {
      print("[ViewModel 에러] 로드 실패: $e");
      _allOfflineRewards = [];
      _updateEditingList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}