import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/repository/setting/setting_repository.dart';
import 'package:frontend/models/setting/parent_model.dart';


class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  ParentModel? _parentData;
  bool _isLoading = false;

  ParentModel? get parentData => _parentData;
  bool get isLoading => _isLoading;

  // [수정] 외부(UI)에서 실제 토큰을 전달받도록 변경
  // setting_view_model.dart 수정 확인
  Future<void> fetchParentInfo(String realToken) async {
    print("🚀 [ViewModel] fetchParentInfo 함수 진입!");
    _isLoading = true;
    notifyListeners();

    try {
      // 🚨 반드시 realToken(매개변수)을 Repository로 넘겨야 합니다!
      final ParentModel? result = await _repository.getParentInfo(realToken);

      if (result != null) {
        _parentData = result;
        print("✅ [ViewModel] 데이터 로드 성공: ${_parentData?.email}");
      } else {
        print("⚠️ [ViewModel] 결과가 null입니다. 서버 DB에 유저가 있는지 확인하세요.");
      }
    } catch (e) {
      print("❌ [ViewModel 에러] 호출 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}