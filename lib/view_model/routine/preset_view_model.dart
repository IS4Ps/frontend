import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth;
import '../../repository/routine/preset_repository.dart';

class PresetViewModel extends ChangeNotifier {
  final PresetRepository _repository = PresetRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _presets = [];
  List<dynamic> get presets => _presets;

  Future<int> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('parentId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("부모 ID가 없습니다.");
  }

  Future<int> _getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('selectedChildId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("자녀 ID가 없습니다.");
  }

  String _getAccessToken() {
    return my_auth.TokenManager().parentToken ?? my_auth.TokenManager().token ?? "";
  }

  Future<bool> savePresetFromDate({
    required String title,
    required String date,
  }) async {
    _isLoading = true;
    notifyListeners();

    final int parentId = await _getParentId();
    final int childId = await _getChildId();

    final body = {
      "parentId": parentId,
      "childId": childId,
      "date": date,
      "title": title,
      "description": "",
    };

    final bool isSuccess = await _repository.savePresetFromDate(body);

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  Future<void> getPresets() async {
    _isLoading = true;
    notifyListeners();

    final int parentId = await _getParentId();
    _presets = await _repository.getPresets(parentId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePreset({
    required int presetId,
    required String title,
  }) async {
    _isLoading = true;
    notifyListeners();

    final body = {
      "title": title,
      "description": "",
      "icon": "default",
      "durationDays": 1,
    };

    final bool isSuccess = await _repository.updatePreset(presetId, body);

    if (isSuccess) await getPresets();

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  Future<bool> deletePreset(int presetId) async {
    _isLoading = true;
    notifyListeners();

    final bool isSuccess = await _repository.deletePreset(presetId);

    if (isSuccess) await getPresets();

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  Future<bool> loadPreset({
    required int presetId,
    required String startDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    final int childId = await _getChildId();

    final body = {
      "childId": childId,
      "startDate": startDate,
      "assignedExpPerMission": 20,
    };

    final bool isSuccess = await _repository.loadPreset(presetId, body);

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }
}