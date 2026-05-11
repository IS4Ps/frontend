import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../models/profile/child_profile_response_model.dart';
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

  /// [자녀 전용] 정보 조회 프로세스 (최종 안정화 버전)
  Future<void> fetchChildInformation(String childId, String deviceId) async {
    // 이미 데이터를 성공적으로 불러왔다면, 불필요한 재호출 및 403 에러 방지를 위해 리턴 고려 가능
    // if (_childInfo != null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 메모리(TokenManager)에 토큰이 없으면 저장소에서 복구
      String? parentToken = my_auth.TokenManager().token;
      if (parentToken == null || parentToken.isEmpty) {
        parentToken = prefs.getString('parentTokenBackup');
        if (parentToken != null) {
          my_auth.TokenManager().setToken(parentToken);
        }
      }

      debugPrint('[ProfileViewModel] 토큰 복구 상태: ${parentToken != null}');

      // 2. 아동 로그인 (부모 권한 사용)
      final loginResponse = await _repository.loginAsChild(deviceId, int.parse(childId));

      if (loginResponse != null && loginResponse['accessToken'] != null) {
        final String childToken = loginResponse['accessToken'];

        // 3. 정보 조회 (부모 토큰 사용)
        // 만약 부모 토큰이 만료되었다면 발급받은 childToken을 fallback으로 사용
        final result = await _repository.getChildInformation(childId, parentToken ?? childToken);

        if (result != null) {
          // ✅ 성공 시 데이터 업데이트
          _childInfo = result;
          debugPrint('[ProfileViewModel] 정보 조회 성공: ${_childInfo?.nickname}');

          // 4. 조회가 성공했을 때만 앱 전역 토큰을 [아동 토큰]으로 변경
          // 이후부터는 다른 아동용 API(퀘스트 등)를 사용할 수 있습니다.
          my_auth.TokenManager().setToken(childToken);
        } else {
          debugPrint('[ProfileViewModel] 정보 조회 결과가 null입니다.');
        }
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 에러 발생: $e');
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
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ProfileViewModel] 생성 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}