import 'package:flutter/material.dart';
import 'speech_bubble.dart'; // 기분 선택 화면 파일 import

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildLevelSection(),
            const SizedBox(height: 20),
            _buildCharacterSection(context),
            const SizedBox(height: 30),
            _buildQuestCard(context),
            const SizedBox(height: 30), // 바텀네비 기준 여백
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Level 1 모험가",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Color(0xFFE3E3E3),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA2FF70)),
              minHeight: 18,
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
                "70%", style: TextStyle(color: Colors.black, fontSize: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSection(BuildContext context) {
    return Stack(
      children: [
        // 수정됨: 나중에 Spline 3D 캐릭터가 들어갈 자리
        Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: Container(
              width: 250,
              height: 310,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE), // 연한 회색 사각형
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "캐릭터 자리",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),


        Positioned(
          top: 0,
          left: 30,
          child: GestureDetector(
            onTap: () {
              // 팝업 호출 함수 실행
              _showMoodPopup(context);
            },
            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                child: const Text(
                  "오늘의 기분은 어때?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),

        // 스탯 박스
        Positioned(
          right: 30,
          bottom: 0,
          child: _buildStatBox(),
        ),
      ],
    );
  }

  void _showMoodPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치 시 닫기
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 배경 투명하게
          insetPadding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 여백
          child: const SpeechBubble(), // 아까 만든 기분 선택 위젯
        );
      },
    );
  }

  Widget _buildQuestCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("퀘스트 상세 화면으로 이동합니다.")));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("다음 퀘스트",
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
                SizedBox(height: 5),
                Text("학원 다녀오기", style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox() {
    return Container(
      width: 104,
      // 전체 박스 가로 가이드
      height: 80,
      // 전체 박스 세로 가이드
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 막대 간격 균등 분배
        children: [
          // 나중에 API에서 0.0 ~ 1.0 사이의 값을 받아와서 넣으면 됩니다.
          _buildMiniBar(const Color(0xFFFF7070), 0.8), // 예: 공격력 80%
          _buildMiniBar(const Color(0xFF54C517), 0.5), // 예: 체력 50%
          _buildMiniBar(const Color(0xFF2194FF), 0.3), // 예: 마나 30%
        ],
      ),
    );
  }

  // value: 0.0 ~ 1.0 사이의 값 (막대 차오르는 정도)
  Widget _buildMiniBar(Color color, double value) {
    return Column(
      children: [
        Stack(
          children: [
            // 배경 회색 바 (빈 공간 표시)
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 실제 데이터가 차오르는 유색 바
            FractionallySizedBox(
              widthFactor: value, // 이 값이 0.8이면 80%가 차오름
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = const Color(0xFFFDFDFD)
      ..style = PaintingStyle.fill;

    final path = Path();
    const double radius = 15.0;
    const double tailWidth = 10.0;
    const double tailHeight = 10.0;
    double tailPosition = size.width * 0.8;

    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height - tailHeight, const Radius.circular(radius)));
    path.moveTo(tailPosition - tailWidth, size.height - tailHeight);
    path.lineTo(tailPosition, size.height);
    path.lineTo(tailPosition + tailWidth, size.height - tailHeight);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 6.0, true);
    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}