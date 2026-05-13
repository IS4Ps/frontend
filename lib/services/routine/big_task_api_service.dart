import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class BigTaskApiService {
  Future<Response> fetchBigTasks(int parentId) async {
    return await DioClient.dio.get('/api/v1/big-tasks', queryParameters: {'parentId': parentId});
  }

  Future<Response> createBigTask(Map<String, dynamic> body) async {
    return await DioClient.dio.post('/api/v1/big-tasks', data: body);
  }
}