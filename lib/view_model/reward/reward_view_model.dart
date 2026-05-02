import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/reward/offline_reward_list_model.dart';
import '../../repository/reward/reward_repository.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardRepository _repository = RewardRepository();

  bool _isLoading = false;
  bool _isWeekly = true; // 주간/월간 탭 상태 관리
  List<OfflineRewardListModel> _allOfflineRewards = [];

  bool get isLoading => _isLoading;
  bool get isWeekly => _isWeekly;

  // 현재 테스트 중인 토큰
  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  // 탭 전환 함수 (주간/월간)
  void togglePeriod(bool isWeekly) {
    _isWeekly = isWeekly;
    notifyListeners(); // 상태 변경 시 UI 자동 업데이트
  }

  // 현재 상태(isWeekly)에 따라 필터링된 리스트 반환
  List<OfflineRewardListModel> get filteredRewards {
    String type = _isWeekly ? "WEEKLY" : "MONTHLY";
    return _allOfflineRewards.where((reward) => reward.periodType == type).toList();
  }

  // 토큰에서 childId 추출 (QuestViewModel 로직 유지)
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

  // 오프라인 보상 목록 조회
  Future<void> fetchOfflineRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final int dynamicChildId = _getChildIdFromToken(_testToken);

      // 주간/월간 구분 로그 추가
      String currentType = _isWeekly ? "WEEKLY(주간)" : "MONTHLY(월간)";
      print("[ViewModel] 오프라인 보상 목록 로드 시작 (childId: $dynamicChildId, 타입: $currentType)");

      final List<OfflineRewardListModel> rewards =
      await _repository.getOfflineRewards(dynamicChildId, _testToken);

      _allOfflineRewards = rewards;

      // 필터링된 결과 개수 로그 출력
      print("[ViewModel] 보상 목록 로드 완료: ${filteredRewards.length}개 ($currentType 기준)");

    } catch (e) {
      print("[ViewModel 에러] 보상 목록 로드 실패: $e");
      _allOfflineRewards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}