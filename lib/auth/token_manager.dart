class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _parentToken; // 부모 전용
  String? _childToken;  // 아이 전용
  bool _isChildMode = false; // 현재 아이 모드 여부

  // --- 토큰 저장 ---
  void setParentToken(String token) {
    _parentToken = token;
    _isChildMode = false;
    print("[TokenManager] 부모 토큰 저장 완료");
  }

  void setChildToken(String token) {
    _childToken = token;
    _isChildMode = true;
    print("[TokenManager] 아이 토큰 저장 완료 (아이 모드 활성화)");
  }

  // --- 토큰 가져오기 ---
  // 현재 모드에 맞는 토큰을 자동으로 반환합니다.
  String? get token => _isChildMode ? _childToken : _parentToken;

  String? get parentToken => _parentToken;
  String? get childToken => _childToken;

  // --- 상태 확인 ---
  bool get hasToken => token != null;
  bool get isChildMode => _isChildMode;

  // --- 초기화 ---
  void clear() {
    _parentToken = null;
    _childToken = null;
    _isChildMode = false;
    print("[TokenManager] 모든 토큰 및 모드 초기화");
  }
}