import 'package:flutter/material.dart';
import 'routine_date_selector.dart';
import 'routine_load_modal.dart';
import 'routine_save_modal.dart';

class RoutineSettingScreen extends StatefulWidget {
  const RoutineSettingScreen({super.key});

  @override
  State<RoutineSettingScreen> createState() => _RoutineSettingScreenState();
}

class _RoutineSettingScreenState extends State<RoutineSettingScreen> {
  bool isFullCalendarOpen = false;
  int selectedDay = 1;
  final TextEditingController _subTaskController = TextEditingController();
  List<String> _subTasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFECF2F8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 상단 헤더 ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          '루틴 & 미션 설정',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontFamily: 'JejuGothic',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: _topActionButton(
                                icon: Icons.save_outlined,
                                text: '반복 루틴 저장',
                                backgroundColor: const Color(0x90E047FF),
                                // ✅ 모달 호출
                                onTap: () {
                                  showRoutineSaveModal(
                                    context,
                                    initialDay: selectedDay,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _topActionButton(
                                icon: Icons.ios_share,
                                text: '루틴 불러오기',
                                backgroundColor: const Color(0x7C1586E2),
                                onTap: () {
                                  showRoutineLoadModal(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 본문 ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 선택
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          '날짜 선택',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'JejuGothic',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ WeekCalendarWidget 사용
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: WeekCalendarWidget(
                          selectedDay: selectedDay,
                          isFullCalendarOpen: isFullCalendarOpen,
                          onDaySelected: (day) =>
                              setState(() => selectedDay = day),
                          onToggleCalendar: () => setState(
                                () => isFullCalendarOpen = !isFullCalendarOpen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 시간 설정
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '시간 설정',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'JejuGothic',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            SizedBox(width: 65, child: _timeBox('8:30')),
                            const SizedBox(width: 8),
                            const Text(
                              '~',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(width: 65, child: _timeBox('9:30')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

// 미션 제목 → 큰 과제/태그선택/세부과제 영역
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 큰 과제
                            const Text(
                              '큰 과제',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0x607C7D7D)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '예: 등교 준비하기',
                                style: TextStyle(
                                  color: Color(0xFF7C7D7D),
                                  fontSize: 16,
                                  fontFamily: 'JejuGothic',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 태그 선택
                            const Text(
                              '태그 선택',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                _TagChip(label: '운동'),
                                _TagChip(label: '공부'),
                                _TagChip(label: '생활'),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 세부 과제
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF2F8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '세부 과제',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontFamily: 'JejuGothic',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._subTasks.map((task) => Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          task,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'JejuGothic',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _subTasks.remove(task);
                                            });
                                          },
                                          child: const Icon(Icons.close, size: 16, color: Color(0xFF7C7D7D)),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 29,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: const Color(0x607C7D7D)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: TextField(
                                            controller: _subTaskController,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'JejuGothic',
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '세부 과제 추가 (예: 세수하기)',
                                              hintStyle: TextStyle(
                                                color: Color(0xFF7C7D7D),
                                                fontSize: 11,
                                                fontFamily: 'JejuGothic',
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          if (_subTaskController.text.isNotEmpty) {
                                            setState(() {
                                              _subTasks.add(_subTaskController.text);
                                              _subTaskController.clear();
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 29,
                                          height: 29,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8AC5F5),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 미션 저장 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1586E2),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              '미션 저장하기 ($selectedDay일 선택됨)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 공통 위젯 ────────────────────────────────────────────────────────────────

Widget _topActionButton({
  required IconData icon,
  required String text,
  required Color backgroundColor,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'JejuGothic',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _timeBox(String text) {
  return Container(
    height: 40,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0x607C7D7D)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7C7D7D),
        fontSize: 14,
        fontFamily: 'JejuGothic',
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x897C7D7D)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'JejuGothic',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}