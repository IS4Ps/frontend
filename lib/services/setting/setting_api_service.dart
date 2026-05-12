import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class SettingApiService {
  // 내 정보 조회
  Future<Response> fetchParentInfo() async {
    return await DioClient.dio.get('/parents/me');
  }
}