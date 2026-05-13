import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  // 싱글톤 패턴 설정
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _accessToken;

  // 초기화 (main 등에서 호출 권장)
  Future<void> init() async {
    _accessToken = await _storage.read(key: 'accessToken');
    print("[TokenManager] 초기화 완료: $_accessToken");
  }

  // 토큰 저장
  Future<void> setToken(String token) async {
    _accessToken = token;
    await _storage.write(key: 'accessToken', value: token);
    print("[TokenManager] 토큰 저장 완료: $_accessToken");
  }

  // 토큰 가져오기
  String? get token => _accessToken;

  // 로그인 여부 확인
  bool get hasToken => _accessToken != null;

  // 🔥 [추가] 토큰 삭제 (로그아웃 시 사용)
  Future<void> clear() async {
    _accessToken = null;
    await _storage.delete(key: 'accessToken');
    print("[TokenManager] 토큰이 삭제되었습니다.");
  }
}