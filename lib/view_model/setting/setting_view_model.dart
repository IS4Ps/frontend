import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/repository/setting/setting_repository.dart';
import 'package:frontend/models/setting/parent_model.dart';


class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  // 상태 관리 변수
  ParentModel? _parentData;
  bool _isLoading = false;

  // UI에서 사용하기 위한 Getter
  ParentModel? get parentData => _parentData;
  bool get isLoading => _isLoading;

  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  // setting_view_model.dart
  Future<void> fetchParentInfo() async {
    // 🚨 이 로그가 찍히는지 확인하는 것이 1순위입니다.
    print("🚀 [ViewModel] fetchParentInfo 함수 진입!");

    _isLoading = true;
    notifyListeners();

    try {
      print("🌐 [ViewModel] API 요청 전송 중... (Token 존재여부: ${_testToken.isNotEmpty})");
      final ParentModel? result = await _repository.getParentInfo(_testToken);

      if (result != null) {
        _parentData = result;
        print("✅ [ViewModel] 데이터 로드 성공: ${_parentData?.email}");
      } else {
        print("⚠️ [ViewModel] 결과가 null입니다. (Repository 확인 필요)");
      }
    } catch (e) {
      print("❌ [ViewModel 에러] 호출 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}