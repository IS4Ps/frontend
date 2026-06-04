import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart'; // 3D 뷰어 패키지 추가
import '../../models/profile/child_information_response_model.dart';
import '../../models/profile/job_list_response_model.dart';
import '../../view_model/profile/profile_view_model.dart';
import '../../view_model/quest/quest_view_model.dart';
import '../../view_model/store/inventory_view_model.dart';
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
  // ✅ 걷어냄: 리렌더링 때 날아가던 로컬 변수 _currentSelectedJobId를 삭제했습니다.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<QuestViewModel>();
        viewModel.loadTodayMood();
        viewModel.fetchTodayMissions();
        viewModel.fetchEquippedItems();

        final profileVM = context.read<ProfileViewModel>();
        profileVM.fetchAvailableJobs();
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
    final profileVM = Provider.of<ProfileViewModel>(context);
    final info = profileVM.childInfo;

    int level = info?.level ?? 1;
    String jobTitle = "모험가";

    // 🚀 [수정] 이제 변하지 않는 ViewModel 전역 변수인 selectedJobId를 바라봅니다.
    if (profileVM.selectedJobId != null) {
      if (profileVM.selectedJobId == 1) jobTitle = "전사";
      else if (profileVM.selectedJobId == 2) jobTitle = "마법사";
      else if (profileVM.selectedJobId == 3) jobTitle = "예술가";
    }

    int currentExp = info?.currentExp ?? 0;
    int maxExp = 1000;
    double expFactor = (currentExp / maxExp).clamp(0.0, 1.0);
    int expPercent = (expFactor * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Level $level $jobTitle", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: expFactor,
              backgroundColor: const Color(0xFFE2E2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA1FF6F)),
              minHeight: 18,
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text("$expPercent%", style: const TextStyle(color: Colors.black, fontSize: 22))),
        ],
      ),
    );
  }

  Widget _buildCharacterSection(BuildContext context, QuestViewModel viewModel) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    String characterModelPath = 'assets/models/character/Rogue.glb';
    if (profileVM.selectedJobId != null) {
      if (profileVM.selectedJobId == 1) {
        characterModelPath = 'assets/models/character/Knight.glb';
      } else if (profileVM.selectedJobId == 2) {
        characterModelPath = 'assets/models/character/Mage.glb';
      } else if (profileVM.selectedJobId == 3) {
        characterModelPath = 'assets/models/character/Ranger.glb';
      }
    }

    debugPrint('I/flutter: 🚨🚨🚨 [CHARACTER BUILD LOG] 🚨🚨🚨');
    debugPrint('I/flutter: 📌 현재 profileVM.selectedJobId 상태값: ${profileVM.selectedJobId}');
    debugPrint('I/flutter: 🎬 최종 ModelViewer에 주입되는 에셋 경로: $characterModelPath');
    debugPrint('I/flutter: ======================================================');

    JobModel? currentJob;
    if (profileVM.jobList.isNotEmpty && profileVM.selectedJobId != null) {
      try {
        currentJob = profileVM.jobList.firstWhere((job) => job.id == profileVM.selectedJobId);
      } catch (_) {
        currentJob = null;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 캐릭터
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
                child: ModelViewer(
                  key: ValueKey(characterModelPath),
                  src: characterModelPath,
                  alt: "Base Character",
                  autoRotate: false,
                  cameraControls: true,
                  disableZoom: true,
                  autoPlay: true,
                  backgroundColor: const Color(0xFFFDFDFD),
                  loading: Loading.eager,
                ),
              ),
            ),
          ),
        ),

        // ✅ 장착 아이템 (ClipRRect 밖)
        ...viewModel.equippedItems.map((item) {
          return Positioned(
            left: 30,
            bottom: 0,
            child: SizedBox(
              width: 105,
              height: 120,
              child: ModelViewer(
                src: 'assets/models/item/${item.splineTriggerName}.glb',
                alt: item.itemName,
                autoRotate: false,
                cameraControls: true,
                disableZoom: true,
                autoPlay: true,
                backgroundColor: Colors.transparent,
                loading: Loading.eager,
              ),
            ),
          );
        }).toList(),

        // 말풍선
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

        // 아이콘 버튼
        Positioned(
          top: 0,
          right: 40,
          child: GestureDetector(
            onTap: () => _showJobSelectionPopup(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.face, size: 30, color: Colors.black),
              ),
            ),
          ),
        ),

        Positioned(right: 30, bottom: 0, child: _buildStatBox(currentJob)),
      ],
    );
  }

  // --- 직업 선택 팝업창 연동 ---
  void _showJobSelectionPopup(BuildContext context) {
    int selectedIndex = -1;
    final profileVM = context.read<ProfileViewModel>();
    final questVM = context.read<QuestViewModel>();
    final inventoryVM = Provider.of<InventoryViewModel>(context, listen: false);  // 추가
    final String? childId = profileVM.childInfo?.childId?.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isSelected = selectedIndex != -1;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildJobItem(0, "전사", "강력한 힘을 자랑하는 전사\n운동을 통해 체력을 기르세요!", selectedIndex == 0, () => setState(() => selectedIndex = 0)),
                    const SizedBox(height: 16),
                    _buildJobItem(1, "마법사", "지혜를 자랑하는 마법사\n공부, 독서를 통해 지혜를 기르세요!", selectedIndex == 1, () => setState(() => selectedIndex = 1)),
                    const SizedBox(height: 16),
                    _buildJobItem(2, "예술가", "자유로운 영혼의 예술가\n예술을 통해 창의력을 기르세요!", selectedIndex == 2, () => setState(() => selectedIndex = 2)),

                    const SizedBox(height: 35),

                    GestureDetector(
                      onTap: isSelected ? () async {
                        if (childId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('자녀 정보가 올바르지 않습니다.')),
                          );
                          return;
                        }

                        int targetJobId = selectedIndex + 1;

                        bool success = await profileVM.updateChildJob(childId, targetJobId);

                        if (success && mounted) {
                          await inventoryVM.loadInventory();
                          for (final item in inventoryVM.items.where((i) => i.isEquipped)) {
                            await inventoryVM.equipItem(item.inventoryId);
                          }
                          await questVM.fetchEquippedItems();
                          Navigator.pop(context);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('직업 선택 실패. 다시 시도해주세요.')),
                          );
                        }
                      } : null,
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.5,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 80),
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4388E2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: isSelected ? [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                            ] : [],
                          ),
                          child: Center(
                            child: profileVM.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                "선택 완료",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "직업 선택의 기회는 한 번밖에 없습니다!\n신중하게 선택하세요!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobItem(int index, String title, String desc, bool isSelected, VoidCallback onTap) {
    List<String> descLines = desc.split('\n');
    String mainDesc = descLines[0];
    String subDesc = descLines.length > 1 ? descLines[1] : "";

    String getImagePath() {
      switch (index) {
        case 0: return 'assets/models/character/Knight.png';
        case 1: return 'assets/models/character/Mage.png';
        case 2: return 'assets/models/character/Ranger.png';
        default: return 'assets/models/character/Rogue.png';
      }
    }

    Color getBorderColor() {
      switch (index) {
        case 0: return const Color(0xFFFF7070);
        case 1: return const Color(0xFF54C517);
        case 2: return const Color(0xFF2194FF);
        default: return const Color(0xFFEEEEEE);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF75F94C) : const Color(0xFFEEEEEE),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getBorderColor(), width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  getImagePath(),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text("사진 없음", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(mainDesc, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subDesc, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.normal, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
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
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
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
                Text(displayTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // 🚀 [에러 교정 완료] JobModel의 base 스탯 값으로 채워지는 스탯 박스 컴포넌트
  Widget _buildStatBox(JobModel? job) {
    // 15 기준 비율 계산
    double strengthRatio = ((job?.baseStrength ?? 1) / 15).clamp(0.1, 1.0);
    double intelligenceRatio = ((job?.baseIntelligence ?? 1) / 15).clamp(0.1, 1.0);
    double creativityRatio = ((job?.baseCreativity ?? 1) / 15).clamp(0.1, 1.0);

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
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        // 💡 오타가 났던 Mainmathbf와 중복 지정되었던 mainAxisAlignment를 깔끔하게 정리했습니다.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniBar(const Color(0xFFFF7070), strengthRatio),     // 힘 (빨강)
          _buildMiniBar(const Color(0xFF54C517), intelligenceRatio), // 지혜 (초록)
          _buildMiniBar(const Color(0xFF2194FF), creativityRatio),   // 창의력 (파랑)
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