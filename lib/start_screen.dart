import 'package:flutter/material.dart';
import 'package:frontend/child_main_screen.dart';
import 'package:frontend/parent_main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/auth/token_manager.dart' as my_auth;

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 1. 앱 시작 시 로그인 상태 체크 (자동 로그인 로직)
  Future<void> _checkLoginStatus() async {
    // 💡 카카오 SDK 세션 확인 + 우리 TokenManager에 토큰이 있는지 확인
    bool hasKakaoToken = await AuthApi.instance.hasToken();
    bool hasMyToken = my_auth.TokenManager().hasToken;

    if (hasKakaoToken && hasMyToken) {
      try {
        await UserApi.instance.accessTokenInfo();
        if (mounted) setState(() => _isLoggedIn = true);
        debugPrint('[자동 로그인] 기존 토큰이 유효합니다.');
      } catch (e) {
        my_auth.TokenManager().clear();
        if (mounted) setState(() => _isLoggedIn = false);
        debugPrint('[자동 로그인] 토큰이 만료되어 삭제되었습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                '루틴 메이트',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D3A70),
                  letterSpacing: -2.5,
                ),
              ),
              const SizedBox(height: 60),
              _buildRoleButton(
                title: '보호자로 시작하기',
                subtitle: _isLoggedIn ? '이미 로그인됨 - 바로 입장' : '자녀의 루틴을 관리하세요',
                onTap: () {
                  // ✨ [수정 완료] 로그인 되어있으면 바로 메인으로, 아니면 팝업 띄우기
                  if (_isLoggedIn) {
                    _navigateToParentMain();
                  } else {
                    _showKakaoLoginDialog(context);
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                title: '아동으로 시작하기',
                subtitle: '오늘의 퀘스트를 확인해요!',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildMainScreen()),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToParentMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ParentMainScreen()),
    );
  }

  void _showKakaoLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("간편 로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            GestureDetector(
              onTap: () async {
                try {
                  debugPrint('🚀 [1단계] 카카오 인증 시작...');
                  bool isInstalled = await isKakaoTalkInstalled();
                  OAuthToken token = isInstalled
                      ? await UserApi.instance.loginWithKakaoTalk()
                      : await UserApi.instance.loginWithKakaoAccount();

                  debugPrint('✅ [2단계] 카카오 토큰 획득 성공');

                  const String baseUrl = "http://100.27.204.252:8080";
                  final response = await http.post(
                    Uri.parse('$baseUrl/auth/kakao'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'accessToken': token.accessToken}),
                  );

                  debugPrint('📢 [3단계] 서버 응답 상태코드: ${response.statusCode}');

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    final Map<String, dynamic> responseData = jsonDecode(response.body);
                    final dynamic data = responseData['data'];

                    if (data != null) {
                      final String? jwtToken = data['accessToken'];
                      if (jwtToken != null) {
                        // 🔑 금고에 JWT 저장
                        my_auth.TokenManager().setToken(jwtToken);
                        debugPrint('💾 TokenManager 저장 완료!');
                      }
                    }

                    if (mounted) {
                      setState(() => _isLoggedIn = true);
                      Navigator.pop(innerContext);
                      _navigateToParentMain();
                    }
                  } else {
                    debugPrint('❌ 서버 연동 실패: ${response.statusCode}');
                  }
                } catch (e) {
                  debugPrint('❌ 로그인 로직 에러: $e');
                }
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('카카오로 로그인하기', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}