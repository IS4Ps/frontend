import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/auth/token_manager.dart';

class DioClient {
  static const String baseUrl = 'http://100.27.204.252:8080';
  
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static bool _isInterceptorAdded = false;

  static Dio get dio {
    if (!_isInterceptorAdded) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          // 1. 요청을 보낼 때 (토큰 자동 삽입)
          onRequest: (options, handler) async {
            final accessToken = TokenManager().accessToken;

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
            // 401 Unauthorized 에러 발생 시 토큰 갱신 시도
            if (e.response?.statusCode == 401) {
              debugPrint('[Dio 에러] 401 발생! 토큰 갱신 시도 중...');
              
              final refreshToken = TokenManager().refreshToken;
              if (refreshToken != null) {
                try {
                  // 토큰 갱신 요청용 별도 Dio 인스턴스 (인터셉터 중복 방지)
                  final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
                  final response = await refreshDio.post(
                    '/auth/token/refresh',
                    options: Options(headers: {'Refresh-Token': refreshToken}),
                  );

                  if (response.statusCode == 200) {
                    final data = response.data['data'];
                    final newAccessToken = data['accessToken'];
                    final newRefreshToken = data['refreshToken'];

                    // 새 토큰 저장
                    await TokenManager().setTokens(newAccessToken, newRefreshToken);

                    // 원래 실패했던 요청에 새 토큰을 넣어서 재시도
                    e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    
                    final retryResponse = await _dio.fetch(e.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                } catch (refreshError) {
                  debugPrint('[Dio 에러] 토큰 갱신 실패: $refreshError');
                  // 리프레시 토큰도 만료되었거나 오류 발생 시 로그인 정보 삭제
                  await TokenManager().clear();
                  // 여기서 로그아웃 처리 또는 로그인 화면 이동 로직 트리거 가능
                }
              }
            } else if (e.response?.statusCode == 403) {
              debugPrint('[Dio 에러] 403 권한 없음!');
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
