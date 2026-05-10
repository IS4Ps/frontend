import 'package:flutter/material.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../repository/profile/profile_respository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- [추가된 부분] 최근 생성된 아이의 ID를 저장할 변수 ---
  int? _lastCreatedChildId;
  int? get lastCreatedChildId => _lastCreatedChildId;

  // 아이 프로필 등록 함수
  Future<bool> createChildProfile({
    required String nickname,
    required String deviceId,
  }) async {
    _isLoading = true;
    _lastCreatedChildId = null; // 요청 시작 시 이전 데이터 초기화
    notifyListeners();

    try {
      final requestModel = ChildProfileRequestModel(
        nickname: nickname,
        lastConnectedDeviceId: deviceId,
      );

      final result = await _repository.createChildProfile(requestModel);

      if (result != null && result.success) {
        debugPrint('[ProfileViewModel] 아이 프로필 생성 성공!');

        // 서버에서 받은 childId를 저장
        _lastCreatedChildId = result.childId;

        debugPrint('생성된 Child ID : $_lastCreatedChildId');
        return true;
      } else {
        debugPrint('[ProfileViewModel] 생성 실패: ${result?.message ?? "응답 없음"}');
        return false;
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 에러 발생: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}