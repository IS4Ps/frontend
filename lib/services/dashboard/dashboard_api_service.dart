import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class DashboardApiService {
  // 월간 캘린더 감정 조회
  Future<Response> fetchMonthlyMood(int childId, int year, int month) async {
    return await DioClient.dio.get(
      '/api/v1/mood-logs/$childId/monthly',
      queryParameters: {'year': year, 'month': month},
    );
  }

  Future<Response> fetchWeeklyStats(int childId) async {
    return await DioClient.dio.get('/api/v1/missions/stats/$childId');
  }
}