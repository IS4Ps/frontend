import 'package:flutter/material.dart';
import 'package:frontend/models/routine/big_task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart' as my_auth;
import '../../repository/routine/big_task_repository.dart';
import '../../repository/routine/mission_repository.dart';

class BigTaskViewModel extends ChangeNotifier {
  final BigTaskRepository _repository = BigTaskRepository();
  final MissionRepository _missionRepository = MissionRepository();

  bool _isLoading = false;
  List<BigTaskModel> _bigTasks = [];

  bool get isLoading => _isLoading;
  List<BigTaskModel> get bigTasks => _bigTasks;

  Future<int> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('parentId');
    if (savedId != null) return int.parse(savedId);
    throw Exception("부모 ID가 없습니다.");
  }

  String _getAccessToken() {
    return my_auth.TokenManager().parentToken ?? my_auth.TokenManager().token ?? "";
  }

  Future<void> loadBigTasks() async {
    _isLoading = true;
    notifyListeners();

    final int parentId = await _getParentId();
    final String token = _getAccessToken();
    _bigTasks = await _repository.getBigTasks(parentId, token) ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBigTask({
    required String title,
    required String startTime,
    required String endTime,
    required List<Map<String, dynamic>> smallTasks,
    required String tag,
  }) async {
    _isLoading = true;
    notifyListeners();

    final int parentId = await _getParentId();
    final String token = _getAccessToken();
    final body = {
      "parentId": parentId,
      "title": title,
      "icon": "default",
      "orderIndex": _bigTasks.length + 1,
      "startTime": startTime,
      "endTime": endTime,
      "smallTasks": smallTasks,
    };

    final bool isSuccess = await _repository.createBigTask(body, token);

    if (isSuccess) {
      await loadBigTasks();
    }

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  Future<bool> createMission({
    required int bigTaskId,
    required int childId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final body = {
      "childId": childId,
      "originBigTaskId": bigTaskId,
      "assignedExp": 20,
      "date": date,
      "startTime": startTime,
      "endTime": endTime,
    };

    return await _missionRepository.createMission(body);
  }
}