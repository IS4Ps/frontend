import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/quest/routine_detail_screen.dart';
import '../../view_model/quest/quest_view_model.dart';
import '../../models/quest/today_mission_model.dart';

class RoutineScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGrowTap;
  const RoutineScreen({super.key, this.onBack, this.onGrowTap});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  bool isExpanded = true;
  int _selectedSubTaskIndex = 0;

  // 하위 태스크 (API 응답에 하위 목록이 없을 경우를 대비한 샘플 데이터)
  final List<Map<String, dynamic>> subTasks = [
    {"title": "양치하기", "isDone": true},
    {"title": "세수하기", "isDone": false},
    {"title": "옷 입기", "isDone": false},
  ];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 미션 목록 API 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuestViewModel>().fetchTodayMissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6389E9)))
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 10),
                _buildAchievementCard(),
                const SizedBox(height: 19),
                _buildActionButton("캐릭터 성장하기!!", const Color(0xFFE9807B), widget.onGrowTap),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("오늘의 퀘스트!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // --- 미션 리스트 영역 ---
                      if (viewModel.todayMissions.isEmpty)
                        _buildEmptyQuestCard() // 데이터가 없을 때 표시될 둥근 상자
                      else
                        ...viewModel.todayMissions.asMap().entries.map((entry) {
                          int idx = entry.key;
                          TodayMissionModel mission = entry.value;

                          if (idx == 0) {
                            return _buildMainQuestCard(mission);
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: _buildLockedQuestCard(mission.bigTaskTitle),
                            );
                          }
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 상단 뒤로가기 버튼
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 24),
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // 퀘스트가 없을 때 표시되는 하얀색 둥근 상자
  Widget _buildEmptyQuestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "오늘 예정된 퀘스트가 없습니다.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("퀘스트 달성률", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.62,
              minHeight: 18,
              backgroundColor: Color(0xFFE2E2E2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6389E9)),
            ),
          ),
          const SizedBox(height: 8),
          const Text("5/8 완료 (62%)", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildMainQuestCard(TodayMissionModel mission) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mission.bigTaskTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineDetailScreen(
                        taskTitle: subTasks[_selectedSubTaskIndex]['title'],
                        mainQuestTitle: mission.bigTaskTitle,
                      ),
                    ),
                  );
                },
                child: _buildStatusLabel(
                  mission.status == "PENDING" ? "퀘스트 시작하기" : "진행 중",
                  const Color(0xFF6389E9),
                  Colors.white,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 20),
            Column(
              children: subTasks.asMap().entries.map((entry) {
                return _buildSubTask(entry.key, entry.value['title'], entry.value['isDone']);
              }).toList(),
            ),
          ],
          IconButton(
            onPressed: () => setState(() => isExpanded = !isExpanded),
            icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTask(int index, String title, bool isDone) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSubTaskIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFC6FF8C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(35),
          border: _selectedSubTaskIndex == index ? Border.all(color: const Color(0xFF6389E9), width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 22, color: isDone ? Colors.black : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedQuestCard(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildStatusLabel("이전 퀘스트 진행 중", const Color(0xFFE3E3E3), Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}