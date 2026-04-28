import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/quest/quest_view_model.dart'; // 경로 확인 필요
import 'grow_screen.dart';
import 'speech_bubble.dart';
import 'routine_screen.dart';
import 'ox_screen.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Provider를 통해 ViewModel 연결
    return ChangeNotifierProvider(
      create: (_) => QuestViewModel(),
      child: Consumer<QuestViewModel>(
        builder: (context, viewModel, child) {
          // --- 기존 화면 전환 로직 유지 ---
          if (viewModel.currentStep == 3) {
            return OxScreen(
              onBack: () => viewModel.changeStep(2),
            );
          }

          if (viewModel.currentStep == 2) {
            return GrowScreen(
              onBack: () => viewModel.changeStep(1),
              onQuizTap: () => viewModel.changeStep(3),
            );
          }

          if (viewModel.currentStep == 1) {
            return RoutineScreen(
              onBack: () => viewModel.changeStep(0),
              onGrowTap: () => viewModel.changeStep(2),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFDFDFD),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _buildLevelSection(),
                  const SizedBox(height: 20),
                  _buildCharacterSection(context, viewModel), // viewModel 전달
                  const SizedBox(height: 30),
                  _buildQuestCard(context, viewModel), // viewModel 전달
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Level 1 모험가",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Color(0xFFE2E2E2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA1FF6F)),
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

  Widget _buildCharacterSection(BuildContext context, QuestViewModel viewModel) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: Container(
              width: 250,
              height: 310,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
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

            // 기록 있어도 팝업 뜨는 경우
            onTap: () async {
              // 최신 상태를 한 번 확인하고
              await viewModel.loadTodayMood();

              // 무조건 팝업을 띄움(수정 가능하게)
              if (context.mounted) {
                _showMoodPopup(context, viewModel);
              }
            },

            // 기록이 있으면 말풍선 선택해도 팝업 안뜸
            // onTap: () async {
            //   await viewModel.loadTodayMood();
            //   // 데이터가 없을 때만 팝업 실행
            //   if (viewModel.feelingData == null || viewModel.feelingData!.primaryEmotion == "NONE") {
            //     _showMoodPopup(context, viewModel);
            //   }
            // },

            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                child: viewModel.isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)
                )
                    : Text(
                  viewModel.message, // ViewModel의 메시지 반영
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 0,
          child: _buildStatBox(),
        ),
      ],
    );
  }

  void _showMoodPopup(BuildContext context, QuestViewModel viewModel) { // ✅ viewModel 추가
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) { // 새로운 BuildContext
        // 🔥 핵심: 기존 viewModel을 다이얼로그 안으로 전달합니다.
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            child: SpeechBubble(),
          ),
        );
      },
    );
  }

  Widget _buildQuestCard(BuildContext context, QuestViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        viewModel.changeStep(1); // setState 대신 viewModel 사용
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
                Text(
                  "다음 퀘스트",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                SizedBox(height: 5),
                Text(
                  "학원 다녀오기",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
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
      height: 80,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniBar(const Color(0xFFFF7070), 0.8),
          _buildMiniBar(const Color(0xFF54C517), 0.5),
          _buildMiniBar(const Color(0xFF2194FF), 0.3),
        ],
      ),
    );
  }

  Widget _buildMiniBar(Color color, double value) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
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

// BubblePainter 클래스는 기존과 동일하므로 유지하시면 됩니다.
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

    path.addRRect(
      RRect.fromLTRBR(
        0,
        0,
        size.width,
        size.height - tailHeight,
        const Radius.circular(radius),
      ),
    );
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