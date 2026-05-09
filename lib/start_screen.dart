import 'package:flutter/material.dart';
import 'package:frontend/child_main_screen.dart';
import 'package:frontend/parent_main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http; // 'http' 에러 해결
import 'dart:convert'; // 'jsonEncode', 'jsonDecode' 에러 해결


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
    _checkLoginStatus(); // 초기 진입 시 로그인 여부만 체크
  }

  // 자동 로그인 상태 체크 (UI 반영용)
  Future<void> _checkLoginStatus() async {
    bool hasToken = await AuthApi.instance.hasToken();
    if (hasToken) {
      try {
        await UserApi.instance.accessTokenInfo();
        if (mounted) setState(() => _isLoggedIn = true);
      } catch (e) {
        await TokenManagerProvider.instance.manager.clear();
        if (mounted) setState(() => _isLoggedIn = false);
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
              // --- 앱 타이틀 UI ---
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

              // --- 보호자 진입 버튼 (연동) ---
              _buildRoleButton(
                title: '보호자로 시작하기',
                subtitle: _isLoggedIn ? '이미 로그인됨 - 바로 입장' : '자녀의 루틴을 관리하세요',
                onTap: () {
                  if (_isLoggedIn) {
                    _navigateToParentMain();
                  } else {
                    _showKakaoLoginDialog(context);
                  }
                },
              ),

              const SizedBox(height: 20),

              // --- 아동 진입 버튼 ---
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

  // 메인 화면 이동 로직
  void _navigateToParentMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ParentMainScreen()),
    );
  }

  // --- 카카오 로그인 연동 팝업 ---
  // --- 카카오 로그인 연동 팝업 ---
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
                  // 1. 카카오 인증
                  bool isInstalled = await isKakaoTalkInstalled();
                  OAuthToken token = isInstalled
                      ? await UserApi.instance.loginWithKakaoTalk()
                      : await UserApi.instance.loginWithKakaoAccount();

                  // 2. 서버로 토큰 전송 및 parentId 확인 (이 부분이 핵심!)
                  const String baseUrl = "http://100.27.204.252:8080";
                  final response = await http.post(
                    Uri.parse('$baseUrl/auth/kakao'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'accessToken': token.accessToken}),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    final Map<String, dynamic> responseData = jsonDecode(response.body);

                    // 로그에 parentId 출력
                    if (responseData['data'] != null) {
                      final int pId = responseData['data']['parentId'];
                      final String email = responseData['data']['email'];

                      debugPrint('====================================');
                      debugPrint('✅ [서버 가입 성공] parentId: $pId');
                      debugPrint('✅ [가입 이메일] email: $email');
                      debugPrint('====================================');
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
                  debugPrint('로그인 실패: $e');
                }
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('카카오로 로그인하기', style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 버튼 위젯 UI
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