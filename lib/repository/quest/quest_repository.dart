import 'package:dio/dio.dart';
import 'package:frontend/models/quest/feeling_model.dart';
import 'package:frontend/models/quest/feeling_request_model.dart';
import 'package:frontend/models/quest/today_mission_model.dart';
import '../../services/quest/quest_api_service.dart';
import 'package:frontend/models/quest/weekly_stats_model.dart';
import 'package:frontend/models/quest/equipped_item_model.dart';
import 'package:frontend/models/quest/n_back_start_request_model.dart';
import 'package:frontend/models/quest/n_back_start_response_model.dart';
import 'package:frontend/models/quest/n_back_submit_request_model.dart';
import 'package:frontend/models/quest/n_back_submit_response_model.dart';
import 'package:frontend/models/quest/go_nogo_start_request_model.dart';
import 'package:frontend/models/quest/go_nogo_start_response_model.dart';
import 'package:frontend/models/quest/go_nogo_submit_request_model.dart';
import 'package:frontend/models/quest/go_nogo_submit_response_model.dart';
import 'package:frontend/models/quest/stroop_start_request_model.dart';
import 'package:frontend/models/quest/stroop_start_response_model.dart';
import 'package:frontend/models/quest/stroop_submit_request_model.dart';
import 'package:frontend/models/quest/stroop_submit_response_model.dart';

class QuestRepository {
  final QuestApiService _apiService = QuestApiService();

  // 오늘 감정 조회
  Future<FeelingModel?> getTodayMood(int childId) async {
    try {
      print("[API 호출] 오늘의 기분 조회 시작 (childId: $childId)");

      final response = await _apiService.fetchTodayMood(childId);

      if (response.statusCode == 200) {
        final body = response.data;
        if (body['data'] != null) {
          return FeelingModel.fromJson(body['data']);
        } else {
          return FeelingModel(primaryEmotion: "NONE", score: 0);
        }
      }
      return null;
    } catch (e) {
      print("[QuestRepository 에러] $e");
      return null;
    }
  }

  // 감정 기록 저장
  Future<bool> registerTodayMood(int childId, String emotion) async {
    try {
      String todayDate = DateTime.now().toString().split(' ')[0];
      final request = FeelingRequestModel(
        childId: childId,
        date: todayDate,
        primaryEmotion: emotion,
      );

      final response = await _apiService.postTodayMood(request);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("[QuestRepository 에러] registerTodayMood: $e");
      return false;
    }
  }

  // 오늘 미션 목록 조회
  Future<List<TodayMissionModel>> getTodayMissions(int childId) async {
    try {
      final response = await _apiService.fetchTodayMissions(childId);
      if (response.statusCode == 200) {
        final body = response.data;
        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          return dataList.map((json) => TodayMissionModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("[QuestRepository 에러] getTodayMissions: $e");
      return [];
    }
  }

  // 주간 달성률 조회 (퀘스트)
  Future<WeeklyStatsModel?> getWeeklyStats(int childId) async {
    try {
      final response = await _apiService.fetchWeeklyStats(childId);
      if (response.statusCode == 200) {
        final body = response.data;
        return WeeklyStatsModel.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      print("[QuestRepository 에러] getWeeklyStats: $e");
      return null;
    }
  }

  // 현재 장착 아이템 조회
  Future<List<EquippedItemModel>> getEquippedItems(int childId) async {
    try {
      final response = await _apiService.fetchEquippedItems(childId);
      if (response.statusCode == 200) {
        final body = response.data;
        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          return dataList.map((json) => EquippedItemModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("[QuestRepository 에러] getEquippedItems: $e");
      return [];
    }
  }

  // n-back 게임 시작
  Future<NBackStartResponseModel?> startNBackGame(NBackStartRequestModel request) async {
    try {
      final response = await _apiService.startNBackGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NBackStartResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] startNBackGame: $e");
    }
    return null;
  }

  // N-Back 게임 정답 제출
  Future<NBackSubmitResponseModel?> submitNBackGame(NBackSubmitRequestModel request) async {
    try {
      final response = await _apiService.submitNBackGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NBackSubmitResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] submitNBackGame: $e");
    }
    return null;
  }

  // Go/No-Go 게임 시작
  Future<GoNoGoStartResponseModel?> startGoNoGoGame(GoNoGoStartRequestModel request) async {
    try {
      final response = await _apiService.startGoNoGoGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GoNoGoStartResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] startGoNoGoGame: $e");
    }
    return null;
  }

  // Go/No-Go 정답 제출
  Future<GoNoGoSubmitResponseModel?> submitGoNoGoGame(GoNoGoSubmitRequestModel request) async {
    try {
      final response = await _apiService.submitGoNoGoGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GoNoGoSubmitResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] submitGoNoGoGame: $e");
    }
    return null;
  }

  // stroop 게임 시작
  Future<StroopStartResponseModel?> startStroopGame(StroopStartRequestModel request) async {
    try {
      final response = await _apiService.startStroopGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StroopStartResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] startStroopGame: $e");
    }
    return null;
  }

  // stroop 정답 제출
  Future<StroopSubmitResponseModel?> submitStroopGame(StroopSubmitRequestModel request) async {
    try {
      final response = await _apiService.submitStroopGame(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StroopSubmitResponseModel.fromJson(response.data);
      }
    } catch (e) {
      print("[QuestRepository 에러] submitStroopGame: $e");
    }
    return null;
  }
}