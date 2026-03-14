import 'package:flutter/material.dart';
import 'package:frontend/screens/quest/routine_detail_screen.dart';
import 'grow_screen.dart';

class RoutineScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGrowTap;
  const RoutineScreen({super.key, this.onBack, this.onGrowTap});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  // 박스가 펼쳐져 있는지 상태를 저장하는 변수
  bool isExpanded = true;

  // 추가: 현재 어떤 항목이 선택되었는지 내부적으로만 저장 (기본값 0: 양치하기)
  int _selectedSubTaskIndex = 0;

  // 나중에 API에서 받아올 데이터 예시
  final List<Map<String, dynamic>> subTasks = [
    {"title": "양치하기", "isDone": false},
    {"title": "세수하기", "isDone": false},
    {"title": "옷 입기", "isDone": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뒤로가기 버튼
            Padding(
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
            ),
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
                  _buildMainQuestCard(),
                  const SizedBox(height: 9),
                  _buildLockedQuestCard("학원 다녀오기"),
                  const SizedBox(height: 15),
                  _buildLockedQuestCard("잘 준비하기"),
                ],
              ),
            ),
          ],
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

  Widget _buildMainQuestCard() {
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
              const Text("등교 준비하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineDetailScreen(
                        taskTitle: subTasks[_selectedSubTaskIndex]['title'],
                        mainQuestTitle: "등교 준비하기",
                      ),
                    ),
                  );
                },
                child: _buildStatusLabel("퀘스트 시작하기", const Color(0xFF6389E9), Colors.white),
              ),
            ],
          ),

          if (isExpanded) ...[
            const SizedBox(height: 20),
            Column(
              children: subTasks.asMap().entries.map((entry) {
                int idx = entry.key;
                var task = entry.value;
                return _buildSubTask(idx, task['title'], task['isDone']);
              }).toList(),
            ),
          ],

          Transform.translate(
            offset: const Offset(0, -5),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              icon: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 28,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // 색상 변경 없이 내부 로직만 수정
  Widget _buildSubTask(int index, String title, bool isDone) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // 클릭 시 내부 인덱스만 조용히 바꿈
          _selectedSubTaskIndex = index;
          // 기존 완료 토글 로직 유지
          subTasks[index]['isDone'] = !subTasks[index]['isDone'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          // 색상은 기존 로직 그대로 유지 (완료면 초록색, 아니면 회색)
          color: isDone ? const Color(0xFFC6FF8C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Icon(
              isDone ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: isDone ? Colors.black : Colors.grey,
            ),
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
      child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}