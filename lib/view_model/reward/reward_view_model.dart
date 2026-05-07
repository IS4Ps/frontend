import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/reward/offline_reward_list_model.dart';
import '../../repository/reward/reward_repository.dart';
import 'package:frontend/models/reward/offline_reward_request_model.dart';

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

    // 서버에서 받아온 데이터 중 현재 타입에 맞는 것 필터링
    List<OfflineRewardListModel> filtered =
    _allOfflineRewards.where((r) => r.periodType == type).toList();

    // 서버 데이터들을 먼저 리스트로 만듦 (최신순 정렬이 필요하면 여기서 정렬)
    _editingRewards = List.from(filtered);

    // 리스트의 가장 앞(0번 인덱스)에 빈 입력 카드를 추가
    _editingRewards.insert(
      0,
      OfflineRewardListModel(
        rewardId: 0,
        periodType: type,
        targetPercent: 0,
        rewardPromiseText: "",
        status: "PENDING",
      ),
    );
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

  // 오프라인 보상 목록 조회
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

  // 오프라인 보상 등록
  Future<void> saveRewardStep(int index) async {
    if (index < 0 || index >= _editingRewards.length) return;

    final reward = _editingRewards[index];

    // 필수 입력값 체크
    if (reward.rewardPromiseText.isEmpty || reward.targetPercent == 0) {
      print("[ViewModel] 보상 내용과 달성률을 입력해주세요.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final int dynamicChildId = _getChildIdFromToken(_testToken);

      // API 명세에 따른 요청 모델 생성
      final request = OfflineRewardRequestModel(
        childId: dynamicChildId,
        periodType: _isWeekly ? "WEEKLY" : "MONTHLY",
        targetPercent: reward.targetPercent,
        rewardPromiseText: reward.rewardPromiseText,
      );

      print("[ViewModel] 오프라인 보상 등록 시작: ${request.toJson()}");

      // Repository를 통해 API 호출 (레포지토리에 registerOfflineReward 함수가 구현되어 있어야 함)
      final bool isSuccess = await _repository.registerOfflineReward(_testToken, request);

      if (isSuccess) {
        print("[ViewModel] 보상 등록 성공");
        // 등록 성공 후 최신 목록을 다시 불러와 화면을 동기화합니다.
        await fetchOfflineRewards();
      } else {
        print("[ViewModel] 보상 등록 실패");
      }
    } catch (e) {
      print("[ViewModel 에러] 등록 중 오류 발생: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}