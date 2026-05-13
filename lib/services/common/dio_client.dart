import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static const String baseUrl = 'http://100.27.204.252:8080';
  
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static bool _isInterceptorAdded = false;

  static Dio get dio {
    if (!_isInterceptorAdded) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          // 1. 요청을 보낼 때 (토큰 자동 삽입)
          onRequest: (options, handler) async {
            final accessToken = await _storage.read(key: 'accessToken');

            if (accessToken != null) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
            debugPrint('[Dio 요청] ${options.method} ${options.path}');
            return handler.next(options);
          },

          // 2. 응답이 왔을 때
          onResponse: (response, handler) {
            debugPrint('[Dio 응답] ${response.statusCode} ${response.requestOptions.path}');
            return handler.next(response);
          },

          // 3. 에러가 났을 때 (401, 403 처리)
          onError: (DioException e, handler) async {
            if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
              debugPrint('[Dio 에러] 권한 없음! ${e.response?.statusCode} - 기존 토큰 삭제');
              await _storage.delete(key: 'accessToken');
              // 필요시 여기서 로그인 화면 이동 로직 트리거 가능
            }
            return handler.next(e);
          },
        ),
      );
      _isInterceptorAdded = true;
    }
    return _dio;
  }
}
