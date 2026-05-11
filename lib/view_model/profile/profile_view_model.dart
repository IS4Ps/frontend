import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../models/profile/child_profile_response_model.dart'; // 모델 임포트 확인
import '../../repository/profile/profile_respository.dart';
import '../../auth/token_manager.dart' as my_auth;

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _lastCreatedChildId;
  int? get lastCreatedChildId => _lastCreatedChildId;

  ChildInformationResponseModel? _childInfo;
  ChildInformationResponseModel? get childInfo => _childInfo;

  String? get currentNickname => _childInfo?.nickname;

  /// [자녀 전용] QR 스캔 후 또는 자녀 앱 실행 시 호출
  Future<void> fetchChildInformation(String childId, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[ProfileViewModel] 아동 로그인 시도 (ID: $childId)');

      // 1. 아동 로그인 (accessToken 발급)
      final loginResponse = await _repository.loginAsChild(childId, deviceId);

      if (loginResponse != null && loginResponse['accessToken'] != null) {
        final String childToken = loginResponse['accessToken'];

        // 2. 아동 전용 토큰 저장 (기존 부모 토큰 덮어쓰기)
        my_auth.TokenManager().setToken(childToken);
        debugPrint('[ProfileViewModel] 아동 전용 토큰 갱신 완료');

        // 3. 발급받은 토큰으로 정보 상세 조회
        final result = await _repository.getChildInformation(childId, childToken);

        if (result != null) {
          _childInfo = result;
          debugPrint('[ProfileViewModel] 정보 조회 성공: ${_childInfo?.nickname}');
        }
      } else {
        debugPrint('[ProfileViewModel] 아동 로그인 실패: 응답이 없거나 토큰이 없습니다.');
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 전체 프로세스 에러 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [보호자 전용] 아이 프로필 생성
  Future<bool> createChildProfile({
    required String nickname,
    required String deviceId,
  }) async {
    _isLoading = true;
    _lastCreatedChildId = null;
    _childInfo = null;
    notifyListeners();

    try {
      final requestModel = ChildProfileRequestModel(
        nickname: nickname,
        lastConnectedDeviceId: deviceId,
      );

      final result = await _repository.createChildProfile(requestModel);

      if (result != null && result.success) {
        _lastCreatedChildId = result.childId;
        debugPrint('[ProfileViewModel] 아이 프로필 생성 성공! ID: $_lastCreatedChildId');

        // ⚠️ 주의: 여기서 fetchChildInformation을 호출하면 안 됩니다!
        // 부모 앱에서는 아동 로그인이 필요 없으며, 호출 시 403 에러가 발생할 수 있습니다.
        // 부모 앱은 생성된 _lastCreatedChildId를 가지고 QR 코드만 보여주면 됩니다.

        return true;
      } else {
        debugPrint('[ProfileViewModel] 생성 실패');
        return false;
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 생성 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}