import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class MissionApiService {
  Future<Response> createMission(Map<String, dynamic> body) async {
    return await DioClient.dio.post('/api/v1/missions', data: body);
  }

  Future<Response> getMissionsByDate(int childId, String date) async {
    return await DioClient.dio.get(
      '/api/v1/missions',
      queryParameters: {'childId': childId, 'date': date},
    );
  }
}