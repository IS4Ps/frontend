import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  // ✅ 싱글톤 패턴 설정 (추상 클래스로 만들면 안 됩니다!)
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _parentToken;
  String? _childToken;
  bool _isChildMode = false;

  // 저장 키 값
  static const String _keyParentToken = 'parent_token';
  static const String _keyChildToken = 'child_token';
  static const String _keyIsChildMode = 'is_child_mode';
  static const String _keySelectedChildId = 'selectedChildId';

  // ✅ [수정된 부분] 앱 시작 시 데이터를 불러오는 함수
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _parentToken = prefs.getString(_keyParentToken);
    _childToken = prefs.getString(_keyChildToken);
    _isChildMode = prefs.getBool(_keyIsChildMode) ?? false;
    print("[TokenManager] 초기화 완료: 부모토큰(${_parentToken != null}), 아이모드($_isChildMode)");
  }

  // 자녀 ID 저장 함수
  Future<void> setSelectedChildId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedChildId, id.toString());
    print("[TokenManager] 자녀 ID 저장 완료: $id");
  }

  // 부모 토큰 저장
  Future<void> setParentToken(String token) async {
    _parentToken = token;
    _isChildMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyParentToken, token);
    await prefs.setBool(_keyIsChildMode, false);
  }

  // 아이 토큰 저장
  Future<void> setChildToken(String token) async {
    _childToken = token;
    _isChildMode = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChildToken, token);
    await prefs.setBool(_keyIsChildMode, true);
  }

  String? get token => _isChildMode ? _childToken : _parentToken;
  String? get parentToken => _parentToken;
  String? get childToken => _childToken;
  bool get isChildMode => _isChildMode;

  Future<void> clear() async {
    _parentToken = null;
    _childToken = null;
    _isChildMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}