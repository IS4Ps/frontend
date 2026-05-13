import 'package:dio/dio.dart';
import '../common/dio_client.dart';
import 'package:frontend/models/reward/offline_reward_request_model.dart';

class RewardApiService {
  // 오프라인 보상 목록 조회
  Future<Response> fetchOfflineRewards(int childId) async {
    return await DioClient.dio.get('/api/v1/offline-rewards/$childId');
  }

  // 오프라인 보상 등록
  Future<Response> postOfflineReward(OfflineRewardRequestModel request) async {
    return await DioClient.dio.post('/api/v1/offline-rewards', data: request.toJson());
  }
}