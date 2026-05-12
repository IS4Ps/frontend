import 'package:dio/dio.dart';
import '../common/dio_client.dart';
import 'package:frontend/models/quest/feeling_request_model.dart';
import 'package:frontend/models/quest/n_back_start_request_model.dart';
import 'package:frontend/models/quest/n_back_submit_request_model.dart';
import 'package:frontend/models/quest/go_nogo_start_request_model.dart';
import 'package:frontend/models/quest/go_nogo_submit_request_model.dart';
import 'package:frontend/models/quest/stroop_start_request_model.dart';
import 'package:frontend/models/quest/stroop_submit_request_model.dart';

class QuestApiService {
  // 오늘 감정 조회
  Future<Response> fetchTodayMood(int childId) async {
    return await DioClient.dio.get('/api/v1/mood-logs/$childId/today');
  }

  // 감정 기록 저장
  Future<Response> postTodayMood(FeelingRequestModel request) async {
    return await DioClient.dio.post('/api/v1/mood-logs', data: request.toJson());
  }

  // 오늘의 미션 목록 조회
  Future<Response> fetchTodayMissions(int childId) async {
    return await DioClient.dio.get('/api/v1/missions/today/$childId');
  }

  // 주간 달성률 조회 (퀘스트)
  Future<Response> fetchWeeklyStats(int childId) async {
    return await DioClient.dio.get('/api/v1/missions/stats/$childId');
  }

  // 현재 장착 아이템 조회
  Future<Response> fetchEquippedItems(int childId) async {
    return await DioClient.dio.get('/api/v1/inventory/$childId/equipped');
  }

  // N-Back 게임 시작
  Future<Response> startNBackGame(NBackStartRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/n-back/start', data: request.toJson());
  }

  // N-Back 정답 제출
  Future<Response> submitNBackGame(NBackSubmitRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/n-back/submit', data: request.toJson());
  }

  // Go/No-Go 게임 시작
  Future<Response> startGoNoGoGame(GoNoGoStartRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/go-no-go/start', data: request.toJson());
  }

  // Go/No-Go 정답 제출
  Future<Response> submitGoNoGoGame(GoNoGoSubmitRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/go-no-go/submit', data: request.toJson());
  }

  // stroop 게임 시작
  Future<Response> startStroopGame(StroopStartRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/stroop/start', data: request.toJson());
  }

  // stroop 정답 제출
  Future<Response> submitStroopGame(StroopSubmitRequestModel request) async {
    return await DioClient.dio.post('/api/v1/minigames/stroop/submit', data: request.toJson());
  }
}