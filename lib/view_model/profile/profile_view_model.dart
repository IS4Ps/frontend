import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../repository/profile/profile_respository.dart';
import '../../auth/token_manager.dart'; // ✅ my_auth 별칭 없이 직접 사용 권장

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _lastCreatedChildId;
  int? get lastCreatedChildId => _lastCreatedChildId;

  ChildInformationResponseModel? _childInfo;
  ChildInformationResponseModel? get childInfo => _childInfo;

  String? get currentNickname => _childInfo?.nickname;

  /// ✅ [보호자 전용] 1단계: 아이 프로필 생성
  Future<bool> createChildProfile({
    required String nickname,
    required String deviceId,
  }) async {
    _isLoading = true;
    _lastCreatedChildId = null;
    notifyListeners();

    try {
      final requestModel = ChildProfileRequestModel(
        nickname: nickname,
        lastConnectedDeviceId: deviceId,
      );

      final result = await _repository.createChildProfile(requestModel);

      if (result != null && result.success) {
        _lastCreatedChildId = result.childId;
        debugPrint('[ProfileViewModel] 프로필 생성 성공 ID: $_lastCreatedChildId');
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

  /// ✅ [보호자 전용] 2단계: QR 생성을 위한 linkToken 발급
  Future<String?> fetchLinkToken(int childId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? linkToken = await _repository.getLinkToken(childId);
      if (linkToken != null) {
        debugPrint('[ProfileViewModel] 링크 토큰 발급 완료: $linkToken');
      }
      return linkToken;
    } catch (e) {
      debugPrint("[ProfileViewModel] 링크 토큰 발급 중 예외 발생: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ [자녀 전용] 3단계: QR 스캔 후 최종 기기 연동 및 아이 토큰 발급
  /// 로그에서 발생하던 403 에러를 잡기 위해 토큰 저장 방식을 완전히 분리했습니다.
  Future<bool> linkDeviceAndLogin(String linkToken, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 서버 연동 요청 (/auth/child/register-by-qr)
      final result = await _repository.registerChildByQr(linkToken, deviceId);

      if (result != null && result['accessToken'] != null) {
        final String childToken = result['accessToken'];
        // ✅ UUID(문자열) 대응을 위해 .toString() 사용
        final String childId = result['childId'].toString();

        // 2. TokenManager에 아이 전용 토큰으로 저장 및 모드 전환
        // 이제부터는 모든 API 호출 시 ROLE_CHILD 권한을 사용하게 됩니다.
        TokenManager().setChildToken(childToken);

        // 3. 휴대폰 저장소(SharedPreferences)에도 영구 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('childToken', childToken);
        await prefs.setString('selectedChildId', childId);
        await prefs.setBool('isChildMode', true);

        // 4. 아이 정보 동기화 (새로 받은 아이 토큰을 사용하게 됨)
        await fetchChildInformation(childId, deviceId);

        debugPrint('[ProfileViewModel] 최종 연동 및 로그인 성공: $childId');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ProfileViewModel] 최종 연동 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ [공통] 아이 정보 상세 조회
  /// childId를 String으로 받아 UUID 파싱 에러(FormatException)를 방지합니다.
  // ProfileViewModel.dart 내부 fetchChildInformation 함수

  Future<void> fetchChildInformation(String childId, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ 핵심: 이 API는 '부모 토큰' 전용이므로 백업된 부모 토큰을 가져옵니다.
      String? parentToken = prefs.getString('parentTokenBackup');

      // 만약 부모 토큰이 없다면 현재 활성화된 토큰(TokenManager)이라도 시도
      String? tokenToUse = parentToken ?? TokenManager().parentToken ?? TokenManager().childToken;

      debugPrint('📡 [API 요청] 아이 정보 조회 - 부모 토큰 사용 시도');

      // API 호출 (부모 토큰 전달)
      final result = await _repository.getChildInformation(childId, tokenToUse ?? "");

      if (result != null) {
        _childInfo = result;
        debugPrint('[ProfileViewModel] 아이 정보 조회 성공!');
      } else {
        debugPrint('[ProfileViewModel] 정보 조회 실패 (결과 null)');
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 정보 조회 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}