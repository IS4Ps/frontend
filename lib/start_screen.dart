import 'package:flutter/material.dart';
import 'package:frontend/child_main_screen.dart';
import 'package:frontend/parent_main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/auth/token_manager.dart' as my_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'child_qr_scanner_screen.dart';

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
    // 1. 아동 자동 로그인 상태 먼저 체크
    _checkChildStatus();
    // 2. 부모 로그인 상태 체크
    _checkLoginStatus();
  }

  // [신규] 저장된 아동 연동 정보가 있는지 확인하는 함수
  Future<void> _checkChildStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isChildMode = prefs.getBool('isChildMode') ?? false;
    String? childId = prefs.getString('selectedChildId');

    if (isChildMode && childId != null) {
      debugPrint('[자동 로그인] 아동 모드 연동 확인됨 (Child ID: $childId)');
      if (mounted) {
        // 이미 연동되어 있다면 아동 메인 화면으로 즉시 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChildMainScreen()),
        );
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    bool hasKakaoToken = await AuthApi.instance.hasToken();
    bool hasMyToken = my_auth.TokenManager().hasToken;

    if (hasKakaoToken && hasMyToken) {
      try {
        await UserApi.instance.accessTokenInfo();
        if (mounted) setState(() => _isLoggedIn = true);
      } catch (e) {
        my_auth.TokenManager().clear();
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
              const Text(
                '루틴 메이트',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                  letterSpacing: -2.5,
                ),
              ),
              const SizedBox(height: 60),

              // 1. 보호자로 가입하기 버튼
              _buildRoleButton(
                title: '보호자로 가입하기',
                subtitle: _isLoggedIn ? '이미 로그인됨 - 바로 입장' : '자녀의 진행 상황을 관리하세요',
                icon: Icons.supervisor_account_rounded,
                iconColor: Colors.blueAccent,
                onTap: () {
                  if (_isLoggedIn) {
                    _navigateToParentMain();
                  } else {
                    _showKakaoLoginDialog(context);
                  }
                },
              ),

              const SizedBox(height: 20),

              // 2. 아동으로 가입하기 버튼
              _buildRoleButton(
                title: '아동으로 가입하기',
                subtitle: '퀘스트를 완료하고 레벨업하세요!',
                icon: Icons.child_care_rounded,
                iconColor: Colors.orangeAccent,
                onTap: () {
                  // QR 스캔 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChildQrScannerScreen()),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                '처음 오셨나요? 보호자 계정을 먼저 만들어주세요!',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // 역할 선택 버튼 위젯
  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 35, color: iconColor.withOpacity(0.8)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                  ),
                ],
              ),
            ),
          ],
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
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("간편 로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            const Text("서비스 이용을 위해 로그인이 필요합니다.", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () async {
                try {
                  bool isInstalled = await isKakaoTalkInstalled();
                  OAuthToken token = isInstalled
                      ? await UserApi.instance.loginWithKakaoTalk()
                      : await UserApi.instance.loginWithKakaoAccount();

                  const String baseUrl = "http://100.27.204.252:8080";
                  final response = await http.post(
                    Uri.parse('$baseUrl/auth/kakao'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'accessToken': token.accessToken}),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    final Map<String, dynamic> responseData = jsonDecode(response.body);
                    final dynamic data = responseData['data'];

                    if (data != null && data['accessToken'] != null) {
                      my_auth.TokenManager().setToken(data['accessToken']);
                    }

                    if (mounted) {
                      setState(() => _isLoggedIn = true);
                      Navigator.pop(innerContext);
                      _navigateToParentMain();
                    }
                  }
                } catch (e) {
                  debugPrint(' 로그인 에러: $e');
                }
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/kakao.png', width: 20, height: 20),
                    const SizedBox(width: 10),
                    const Text('카카오로 로그인하기', style: TextStyle(color: Color(0xFF3C1E1E), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}