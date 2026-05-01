import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart'; // 3D 뷰어 패키지 추가
import '../../view_model/quest/quest_view_model.dart';
import 'grow_screen.dart';
import 'speech_bubble.dart';
import 'routine_screen.dart';
import 'ox_screen.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<QuestViewModel>();
        viewModel.loadTodayMood();
        viewModel.fetchTodayMissions();
        viewModel.fetchEquippedItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentStep == 3) {
          return OxScreen(onBack: () => viewModel.changeStep(2));
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
                _buildCharacterSection(context, viewModel),
                const SizedBox(height: 30),
                _buildQuestCard(context, viewModel),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Level 1 모험가", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
          const Center(child: Text("70%", style: TextStyle(color: Colors.black, fontSize: 22))),
        ],
      ),
    );
  }

  // 1. 함수 찾기
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
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack( // 모델들을 겹치기 위해 내부에서 다시 Stack 사용
                  children: [
                    // 1. 기본 캐릭터 모델
                    const ModelViewer(
                      src: 'assets/models/character/Ranger.glb',
                      alt: "Base Character",
                      autoRotate: false,
                      cameraControls: true,
                      disableZoom: true,
                      autoPlay: true,
                      backgroundColor: Color(0xFFFDFDFD),
                      loading: Loading.eager,
                    ),

                    // 2. 장착된 아이템 리스트를 순회하며 위에 얹기
                    ...viewModel.equippedItems.map((item) {
                      return ModelViewer(
                        src: 'assets/models/item/${item.splineTriggerName}.glb',
                        alt: item.itemName,
                        autoRotate: false,
                        cameraControls: false, // 아이템 모델은 컨트롤 비활성화 (캐릭터에 고정된 느낌)
                        disableZoom: true,
                        autoPlay: true,
                        backgroundColor: Colors.transparent, // 배경을 투명하게 해서 캐릭터가 보이게 함
                        loading: Loading.eager,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 말풍선 및 스태스 박스 (기존 코드 유지)
        Positioned(
          top: 0,
          left: 30,
          child: GestureDetector(
            onTap: () async {
              await viewModel.loadTodayMood();
              if (mounted) {
                _showMoodPopup(context, viewModel);
              }
            },
            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                child: viewModel.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey))
                    : Text(
                  viewModel.message,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        Positioned(right: 30, bottom: 0, child: _buildStatBox()),
      ],
    );
  }

  void _showMoodPopup(BuildContext context, QuestViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
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
    String displayTitle = "진행 중인 퀘스트가 없어요";
    if (viewModel.todayMissions.isNotEmpty) {
      displayTitle = viewModel.todayMissions.first.bigTaskTitle;
    }

    return GestureDetector(
      onTap: () => viewModel.changeStep(1),
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
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("다음 퀘스트", style: TextStyle(color: Colors.grey, fontSize: 18)),
                const SizedBox(height: 5),
                Text(
                  displayTitle,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
      width: 104, height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
            Container(width: double.infinity, height: 8, decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(widthFactor: value, child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
          ],
        ),
      ],
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()..color = const Color(0xFFFDFDFD)..style = PaintingStyle.fill;
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