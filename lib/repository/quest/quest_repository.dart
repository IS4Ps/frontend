import 'dart:convert';
import 'package:frontend/models/quest/feeling_model.dart';
import 'package:frontend/models/quest/feeling_request_model.dart';
import 'package:frontend/models/quest/today_mission_model.dart'; // 모델 임포트 확인
import '../../services/quest/quest_api_service.dart';
import 'package:frontend/models/quest/weekly_stats_model.dart';
import 'package:frontend/models/quest/equipped_item_model.dart';

class QuestRepository {
  final QuestApiService _apiService = QuestApiService();

  // 오늘 감정 조회
  Future<FeelingModel?> getTodayMood(int childId, String token) async {
    try {
      print("[API 호출] 오늘의 기분 조회 시작 (childId: $childId)");

      final response = await _apiService.fetchTodayMood(childId, token);

      if (response.statusCode == 200) {
        print("[API 성공] 상태 코드: ${response.statusCode}");
        print("[응답 데이터] ${response.body}");

        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['data'] != null) {
          return FeelingModel.fromJson(body['data']);
        } else {
          print("[데이터 분석] 성공했지만 'data'가 비어있어 'NONE'을 반환합니다.");
          return FeelingModel(primaryEmotion: "NONE", score: 0);
        }
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}");
        print("[에러 내용] ${response.body}");
        return null;
      }
    } catch (e) {
      print("[Repository 에러] 네트워크/런타임 문제 발생: $e");
      return null;
    }
  }

  // 감정 기록 저장
  Future<bool> registerTodayMood(String token, int childId, String emotion) async {
    try {
      // 오늘 날짜 생성
      String todayDate = DateTime.now().toString().split(' ')[0];

      final request = FeelingRequestModel(
        childId: childId,
        date: todayDate,
        primaryEmotion: emotion,
      );

      final response = await _apiService.postTodayMood(token, request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[API 성공] 기분 등록 완료");
        return true;
      } else {
        print("[API 실패] 코드: ${response.statusCode}, 내용: ${response.body}");
        return false;
      }
    } catch (e) {
      print("[Repository 에러]: $e");
      return false;
    }
  }

  // 오늘 미션 목록 조회
  Future<List<TodayMissionModel>> getTodayMissions(int childId, String token) async {
    try {
      print("[API 호출] 오늘의 미션 목록 조회 시작 (childId: $childId)");

      final response = await _apiService.fetchTodayMissions(childId, token);

      if (response.statusCode == 200) {
        print("[API 성공] 상태 코드: ${response.statusCode}");

        // 응답 본문 디코딩 (한글 깨짐 방지)
        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];

          // JSON 리스트를 TodayMissionModel 리스트로 변환
          return dataList.map((json) => TodayMissionModel.fromJson(json)).toList();
        } else {
          print("[데이터 분석] 'data' 필드가 비어있거나 리스트 형식이 아닙니다.");
          return [];
        }
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.body}");
        return [];
      }
    } catch (e) {
      print("[Repository 에러] 미션 목록 로드 중 문제 발생: $e");
      return [];
    }
  }

  // 주간 달성률 조회 (퀘스트)
  Future<WeeklyStatsModel?> getWeeklyStats(int childId, String token) async {
    try {
      // Dio 대신 프로젝트에서 사용하는 apiService의 http 호출 사용
      final response = await _apiService.fetchWeeklyStats(childId, token);

      if (response.statusCode == 200) {
        // http 패키지는 response.body를 직접 decode해야 합니다.
        final Map<String, dynamic> decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return WeeklyStatsModel.fromJson(decodedData['data']);
      }
      return null;
    } catch (e) {
      print("통계 API 레포지토리 에러: $e");
      return null;
    }
  }

  // 현재 장착 아이템 조회 추가
  Future<List<EquippedItemModel>> getEquippedItems(int childId, String token) async {
    try {
      print("[API 호출] 현재 장착 아이템 조회 시작 (childId: $childId)");

      final response = await _apiService.fetchEquippedItems(childId, token);

      if (response.statusCode == 200) {
        print("[API 성공] 장착 아이템 로드 완료");

        // 한글 깨짐 방지 디코딩
        final body = jsonDecode(utf8.decode(response.bodyBytes));

        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];

          // JSON 리스트를 EquippedItemModel 리스트로 변환
          return dataList
              .map((json) => EquippedItemModel.fromJson(json))
              .toList();
        } else {
          print("[데이터 분석] 장착된 아이템 데이터가 없습니다.");
          return [];
        }
      } else {
        print("[API 실패] 상태 코드: ${response.statusCode}, 내용: ${response.body}");
        return [];
      }
    } catch (e) {
      print("[Repository 에러] 장착 아이템 로드 중 문제 발생: $e");
      return [];
    }
  }
}