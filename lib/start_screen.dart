import 'package:flutter/material.dart';
import 'package:frontend/child_main_screen.dart';
import 'package:frontend/parent_main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoggedIn = false; // 로그인 상태 저장 변수

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 앱 실행 시 로그인 상태 확인
  }

  // === 수정된 로그인 상태 확인 로직 ===
  Future<void> _checkLoginStatus() async {
    // 1. 카카오 토큰이 로컬에 존재하는지 먼저 확인
    bool hasToken = await AuthApi.instance.hasToken();

    if (hasToken) {
      try {
        // 2. 토큰이 있다면 유효한지 서버에 물어봄
        await UserApi.instance.accessTokenInfo();
        if (mounted) {
          setState(() {
            _isLoggedIn = true; // 유효할 때만 true
          });
          debugPrint('✅ 자동 로그인 가능: 이전 로그인 기록 확인됨');
        }
      } catch (error) {
        debugPrint('❌ 토큰 만료 또는 유효하지 않음: $error');
        // 토큰이 있지만 유효하지 않다면 확실하게 비워줌
        await TokenManagerProvider.instance.manager.clear();
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
          });
        }
      }
    } else {
      // 3. 토큰이 아예 없다면 (로그아웃 상태) 확실히 false로 설정
      debugPrint('ℹ️ 로그인 기록 없음: 초기 상태로 시작');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  // 백엔드 서버로 토큰 전달 함수
  Future<bool> _sendTokenToBackend(String accessToken) async {
    try {
      const String baseUrl = "http://100.27.204.252:8080";
      debugPrint('요청 전송 중... 주소: $baseUrl/auth/kakao');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/kakao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      debugPrint('====================================');
      debugPrint('서버 응답 상태 코드: ${response.statusCode}');
      debugPrint('서버 응답 바디 내용: ${response.body}');
      debugPrint('====================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ 백엔드 인증 성공');
        return true;
      } else {
        debugPrint('❌ 백엔드 인증 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🚨 네트워크 통신 자체 실패: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 69),
                const Text(
                  '루틴 메이트',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 60),

                // 1. 보호자 버튼
                _buildRoleButton(
                  title: '보호자로 가입하기',
                  // _isLoggedIn 상태에 따라 자막을 다르게 표시
                  subtitle: _isLoggedIn ? '이미 로그인됨 - 바로 입장하기' : '자녀의 진행 상황을 관리하세요',
                  onTap: () {
                    if (_isLoggedIn) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ParentMainScreen()),
                      );
                    } else {
                      _showKakaoLoginDialog(context);
                    }
                  },
                ),

                const SizedBox(height: 40),

                // 2. 아동 버튼
                _buildRoleButton(
                  title: '아동으로 가입하기',
                  subtitle: '퀘스트를 완료하고 레벨업하세요!',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChildMainScreen()),
                    );
                  },
                ),

                const SizedBox(height: 25),
                const Text(
                  '처음 오셨다면 회원가입을 해주세요!',
                  style: TextStyle(color: Color(0xFF7C7D7D), fontSize: 14),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(15)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKakaoLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("간편 로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () async {
                  try {
                    bool isInstalled = await isKakaoTalkInstalled();
                    OAuthToken token = isInstalled
                        ? await UserApi.instance.loginWithKakaoTalk()
                        : await UserApi.instance.loginWithKakaoAccount();

                    bool isBackendSuccess = await _sendTokenToBackend(token.accessToken);

                    if (isBackendSuccess && mounted) {
                      // 가입 성공 시 _isLoggedIn 상태를 true로 업데이트해서 버튼 UI 반영
                      setState(() {
                        _isLoggedIn = true;
                      });
                      Navigator.pop(innerContext);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ParentMainScreen()),
                      );
                    }
                  } catch (error) {
                    debugPrint('카카오 로그인 실패: $error');
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(color: const Color(0xFFFEE500), borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text('카카오로 로그인하기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}