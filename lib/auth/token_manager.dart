import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  // 싱글톤 패턴 설정
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  // 초기화 (main 등에서 호출 권장)
  Future<void> init() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _refreshToken = await _storage.read(key: 'refreshToken');
    print("[TokenManager] 초기화 완료: AccessToken=$_accessToken, RefreshToken=$_refreshToken");
  }

  // 토큰 저장
  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    print("[TokenManager] 토큰 저장 완료");
  }

  // 액세스 토큰 가져오기
  String? get accessToken => _accessToken;

  // 리프레시 토큰 가져오기
  String? get refreshToken => _refreshToken;

  // 로그인 여부 확인
  bool get hasToken => _accessToken != null;

  // 🔥 [추가] 토큰 삭제 (로그아웃 시 사용)
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    print("[TokenManager] 토큰이 삭제되었습니다.");
  }
}