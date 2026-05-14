import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 추가
import 'package:frontend/auth/token_manager.dart' as my_auth; // ✅ 별칭 추가
import 'package:frontend/repository/setting/setting_repository.dart';
import 'package:frontend/models/setting/parent_model.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  ParentModel? _parentData;
  bool _isLoading = false;

  ParentModel? get parentData => _parentData;
  bool get isLoading => _isLoading;

  Future<void> fetchParentInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ParentModel? result = await _repository.getParentInfo();

      if (result != null) {
        _parentData = result;

        // ✅ [핵심 추가] 서버에서 받아온 실제 부모 ID를 SharedPreferences에 저장
        // 이렇게 저장해둬야 빅태스크 조회 등 부모 ID가 필요한 API에서 '1'이 아닌 실제 ID를 씁니다.
        if (_parentData?.parentId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('parentId', _parentData!.parentId.toString());

          debugPrint('[SettingViewModel] 부모 ID 저장 완료: ${_parentData?.parentId}');
        }

        debugPrint('[SettingViewModel] 내 정보 조회 성공!');
        debugPrint('Email     : ${_parentData?.email}');
      } else {
        debugPrint('[SettingViewModel] 결과 데이터가 null입니다.');
      }
    } catch (e) {
      debugPrint('[SettingViewModel] 에러 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}