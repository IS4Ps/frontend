import 'package:flutter/material.dart';

class GrowScreen extends StatelessWidget {
  const GrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 500,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "성장하러 가볼까요?",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F1F1F),
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(2, 2),
                                blurRadius: 4
                            ),
                            Shadow(
                                color: Colors.black.withOpacity(0.08),
                                offset: const Offset(0, 4),
                                blurRadius: 10
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 하단 무지개 도트 포인트 (아이콘 대신 귀여움을 채워줌)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDot(const Color(0xFFFFB7B2)),
                          _buildDot(const Color(0xFFFFDAC1)),
                          _buildDot(const Color(0xFFE2F0CB)),
                          _buildDot(const Color(0xFFB5EAD7)),
                          _buildDot(const Color(0xFFC7CEEA)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // 메뉴 카드 리스트
              _buildChildGrowCard(
                title: "미니게임 하러가기",
                subtitle: "재미있는 미니게임으로 골드 모으기!",
                icon: Icons.sports_esports_rounded,
                gradient: [const Color(0xFF63AFFF), const Color(0xFF8FD8FF)],
                onTap: () => print("미니게임 클릭"),
              ),

              const SizedBox(height: 20),

              _buildChildGrowCard(
                title: "집중하기",
                subtitle: "집중력 쑥쑥! 타이머로 시간 관리하기",
                icon: Icons.timer_rounded,
                gradient: [const Color(0xFF8CD85A), const Color(0xFFB5E385)],
                onTap: () => print("집중하기 클릭"),
              ),

              const SizedBox(height: 20),

              _buildChildGrowCard(
                title: "퀴즈 풀러가기",
                subtitle: "매일매일 똑똑해지는 AI 퀴즈 도전!",
                icon: Icons.auto_awesome_rounded,
                gradient: [const Color(0xFFD644FC), const Color(0xFFF17AC8)],
                onTap: () => print("퀴즈 클릭"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 타이틀 아래 점들을 만드는 헬퍼 위젯
  Widget _buildDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // 아동용 공통 카드 위젯
  Widget _buildChildGrowCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 145,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -5,
              child: Icon(
                icon,
                size: 110,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 42, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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