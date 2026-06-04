import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth; // 프로젝트 경로 확인 필수
import '../../models/profile/child_profile_request_model.dart';
import '../../models/profile/child_information_response_model.dart';
import '../../models/profile/job_list_response_model.dart';
import '../../repository/profile/profile_respository.dart';
import '../../auth/token_manager.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _lastCreatedChildId;
  int? get lastCreatedChildId => _lastCreatedChildId;

  ChildInformationResponseModel? _childInfo;
  ChildInformationResponseModel? get childInfo => _childInfo;

  String? get currentNickname => _childInfo?.nickname;

  // 🚀 [추가] 서버에서 받아온 전체 직업 목록을 저장할 리스트 변수
  List<JobModel> _jobList = [];
  List<JobModel> get jobList => _jobList;

  // 🚀 [핵심 추가] 사용자가 선택 완료한 직업 ID를 뷰모델 레이어에서 영구 기억합니다.
  int? _selectedJobId;
  int? get selectedJobId => _selectedJobId;

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
  Future<bool> linkDeviceAndLogin(String linkToken, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.registerChildByQr(linkToken, deviceId);

      if (result != null && result['accessToken'] != null) {
        final String childToken = result['accessToken'];
        final String childId = result['childId'].toString();

        TokenManager().setChildToken(childToken);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('childToken', childToken);
        await prefs.setString('selectedChildId', childId);
        await prefs.setBool('isChildMode', true);

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
  Future<void> fetchChildInformation(String childId, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? parentToken = prefs.getString('parentTokenBackup');
      String? tokenToUse = parentToken ?? TokenManager().parentToken ?? TokenManager().childToken;

      debugPrint('📡 [API 요청] 아이 정보 조회 - 부모 토큰 사용 시도');

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

  // 이미 연동된 기기용 자동 로그인
  Future<bool> fetchChildAutoInformation(String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[ProfileViewModel] 기기 ID 기반 자동 로그인 시도...');

      final loginResponse = await _repository.loginAsChildAuto(deviceId);

      if (loginResponse != null && loginResponse['accessToken'] != null) {
        final String childToken = loginResponse['accessToken'];

        await my_auth.TokenManager().setChildToken(childToken);
        debugPrint('[ProfileViewModel] 아동 전용 토큰 저장 및 아동 모드 활성화 완료');
        return true;
      } else {
        debugPrint('[ProfileViewModel] 자동 로그인 실패: Token 이 없습니다.');
        return false;
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 자동 로그인 프로세스 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------
  // 🚀 직업 관련 API 연동 메서드 영역
  // -----------------------------------------------------------------

  /// ✅ 전체 직업 목록 가져오기 (인증 불필요)
  Future<void> fetchAvailableJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.fetchJobList();
      if (result != null) {
        _jobList = result;
        debugPrint('[ProfileViewModel] 직업 목록 로드 완료 (${_jobList.length}개)');
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] 직업 목록 로드 중 예외 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ 아이 캐릭터 직업 선택 및 변경 처리 (부모 권한 필요)
  Future<bool> updateChildJob(String childId, int jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? parentToken = TokenManager().parentToken;

      if (parentToken == null) {
        debugPrint('[ProfileViewModel] 오류: 부모 토큰이 유효하지 않아 직업을 바꿀 수 없습니다.');
        return false;
      }

      final result = await _repository.selectChildJob(childId, jobId, parentToken);

      if (result != null) {
        debugPrint('[ProfileViewModel] 캐릭터 직업 변경 성공! 전송한 jobId: $jobId');

        // 🔥 [중요 수정] 서버 성공 통신이 완료되면 뷰모델 전역 메모리에 selectedJobId를 꽉 쥐어줍니다.
        _selectedJobId = jobId;
        notifyListeners(); // 1차 새로고침 알림 (QuestScreen이 캐치해서 바로 Ranger.glb로 교체)

        // 이후 아이 정보 조회가 호출되어 화면이 흔들려도 변하지 않는 안정장치가 마련됩니다.
        await fetchChildInformation(childId, parentToken);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ProfileViewModel] 직업 선택 프로세스 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 완료한 퀘스트 수, 연속 달성 일수
  int _completedQuestCount = 0;
  int _streakDays = 0;

  int get completedQuestCount => _completedQuestCount;
  int get streakDays => _streakDays;

  Future<void> fetchMonthlyStats(String childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? parentToken = prefs.getString('parentTokenBackup');
      String? tokenToUse = parentToken ?? TokenManager().parentToken ?? TokenManager().childToken;

      final now = DateTime.now();
      final result = await _repository.getMonthlyStats(childId, tokenToUse ?? "", now.year, now.month);

      if (result != null) {
        final dailyList = result['dailyList'] as List;
        debugPrint('[ProfileViewModel] dailyList: $dailyList');

        // 완료한 퀘스트 수 합산
        _completedQuestCount = dailyList.fold(0, (sum, day) => sum + (day['completedCount'] as int));

        // 연속 달성 일수 계산
        final today = DateTime.now();
        final pastList = dailyList.where((day) {
          final date = DateTime.parse(day['date']);
          return !date.isAfter(today);
        }).toList().reversed.toList();

        int streak = 0;
        for (final day in pastList) {
          if (day['isSuccess'] == true) {
            streak++;
          } else {
            break;
          }
        }
        _streakDays = streak;

        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProfileViewModel] fetchMonthlyStats 에러: $e');
    }
  }
}