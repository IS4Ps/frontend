import 'package:flutter/material.dart';
import 'package:frontend/child_main_screen.dart';
import 'package:frontend/parent_main_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFBFB),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 69), // 상단 여백

                // 1. 앱 타이틀
                const Text(
                  '앱 이름',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -1.2,
                  ),
                ),

                // 2. 타이틀과 버튼 사이의 공간
                const SizedBox(height: 60),

                // 3. 보호자 버튼
                _buildRoleButton(
                  title: '보호자로 가입하기',
                  subtitle: '자녀의 진행 상황을 관리하세요',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ParentMainScreen())
                    );
                  },
                ),

                const SizedBox(height: 40),

                // 4. 아동 버튼
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

                // 5. 버튼 바로 밑에 텍스트 배치
                const SizedBox(height: 25),
                const Text(
                  '처음 오셨다면 회원가입을 해주세요!',
                  style: TextStyle(
                    color: Color(0xFF7C7D7D),
                    fontSize: 14,
                  ),
                ),

                // 6. 하단 여백 조절을 위한 공간
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 역할 선택 버튼 위젯
  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}