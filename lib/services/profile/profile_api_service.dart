import 'package:dio/dio.dart';
import '../common/dio_client.dart';

class ProfileApiService {
  // 아이 프로필 생성
  Future<Response> postChildProfile(Map<String, dynamic> data) async {
    return await DioClient.dio.post(
      '/children',
      data: data,
    );
  }
}