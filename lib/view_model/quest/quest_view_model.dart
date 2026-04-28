import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/quest/feeling_model.dart';
import '../../repository/quest/quest_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuestViewModel extends ChangeNotifier {
  final QuestRepository _repository = QuestRepository();

  int _currentStep = 0;
  bool _isLoading = false;
  String _message = "오늘의 기분은 어때?";
  FeelingModel? _feelingData;

  int get currentStep => _currentStep;

  bool get isLoading => _isLoading;

  String get message => _message;

  FeelingModel? get feelingData => _feelingData;

  void changeStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // 현재 테스트 중인 토큰
  final String _testToken = dotenv.env['TEST_TOKEN'] ?? "";

  // 토큰의 Payload에서 'sub' 값을 추출하는 함수
  int _getChildIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;

      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final String decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);

      return int.parse(json['sub'].toString());
    } catch (e) {
      print("토큰 디코딩 에러: $e");
      return 1;
    }
  }

  // API 호출
  Future<void> loadTodayMood() async {
    _isLoading = true;
    _message = "가져오는 중...";
    notifyListeners();

    final int dynamicChildId = _getChildIdFromToken(_testToken);
    print("현재 토큰의 실제 아이 ID: $dynamicChildId");

    _feelingData = await _repository.getTodayMood(dynamicChildId, _testToken);

    if (_feelingData != null) {
      if (_feelingData!.primaryEmotion == "NONE" ||
          _feelingData!.primaryEmotion == "기록 없음") {
        _message = "오늘의 기분은 어때?";
      } else {
        print("불러온 감정: ${_feelingData!.primaryEmotion}");
        _message = "오늘은 ${_feelingData!.primaryEmotion}!";
      }
    } else {
      _message = "서버 연결에 실패했어요.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // 기분 저장 로직
  Future<void> saveFeeling(String selectedEmotion) async {
    _isLoading = true;
    notifyListeners();

    // 토큰에서 아이디 추출
    final int dynamicChildId = _getChildIdFromToken(_testToken);

    // Repository 함수 호출 (아이디 포함)
    final bool isSuccess = await _repository.registerTodayMood(
        _testToken, dynamicChildId, selectedEmotion);

    if (isSuccess) {
      print("저장 성공! 최신 데이터를 불러옵니다.");
      await loadTodayMood(); // 여기서 다시 조회해서 말풍선을 바꾼다
    } else {
      _message = "기분 저장에 실패했어요.";
      _isLoading = false;
      notifyListeners();
    }
  }
}