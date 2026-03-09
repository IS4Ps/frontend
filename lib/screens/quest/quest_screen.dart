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
            const SizedBox(height: 50), // 상단 여백
            _buildLevelSection(),
            const SizedBox(height: 20), // 퍼센트와 말풍선 여백
            _buildCharacterSection(context),
            const SizedBox(height: 30), // 캐릭터랑 다음 퀘스트 여백
            _buildQuestCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // 텍스트 왼쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Level 1 모험가", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
              "70%",
              style: TextStyle(color: Colors.black, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: GestureDetector(
            onTap: () {
              // 1. SnackBar 대신 실제 SpeechBubble 화면으로 이동하도록 수정
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SpeechBubble()),
              );
            },
            // 2. CustomPaint를 사용하여 꼬리 달린 말풍선 모양 구현
            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18), // 꼬리 공간을 위한 하단 패딩
                child: const Text(
                  "오늘의 기분은 어때?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50), // 말풍선 꼬리와 겹치지 않게 간격 조정
          child: Image.asset('assets/character.png', height: 250, errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 250, color: Colors.grey);
          }),
        ),
        Positioned(
          right: 60,
          bottom: 40,
          child: _buildStatBox(),
        ),
      ],
    );
  }

  Widget _buildQuestCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("퀘스트 상세 화면으로 이동합니다.")),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("다음 퀘스트", style: TextStyle(color: Colors.grey, fontSize: 18)),
                SizedBox(height: 5),
                Text("학원 다녀오기", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          _buildMiniBar(Colors.redAccent),
          const SizedBox(height: 4),
          _buildMiniBar(Colors.greenAccent),
          const SizedBox(height: 4),
          _buildMiniBar(Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildMiniBar(Color color) {
    return Container(
      width: 30,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ### 말풍선 꼬리를 그리는 클래스 (QuestScreen 클래스 바깥에 위치) ###
class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    double radius = 15.0;
    double tailWidth = 10.0;
    double tailHeight = 10.0;
    // 꼬리 위치를 이미지처럼 살짝 오른쪽(70% 지점)으로 배치
    double tailPosition = size.width * 0.7;

    // 둥근 사각형 몸통 그리기
    path.addRRect(RRect.fromLTRBR(
        0, 0, size.width, size.height - tailHeight, Radius.circular(radius)));

    // 아래쪽 삼각형 꼬리 그리기
    path.moveTo(tailPosition - tailWidth, size.height - tailHeight);
    path.lineTo(tailPosition, size.height);
    path.lineTo(tailPosition + tailWidth, size.height - tailHeight);
    path.close();

    // 부드러운 그림자 효과 추가
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}