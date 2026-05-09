import 'package:flutter/material.dart';
import '../routine/routine_date_selector.dart';

class MissionManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MissionManagementScreen({super.key, this.onBack});

  @override
  State<MissionManagementScreen> createState() => _MissionManagementScreenState();
}

class _MissionManagementScreenState extends State<MissionManagementScreen> {
  int selectedDay = DateTime.now().day;
  bool isFullCalendarOpen = false;

  // 임시 더미 데이터
  final List<Map<String, dynamic>> missions = [
    {
      'title': '등교 준비하기',
      'smallTasks': ['양치하기', '세수하기', '옷 입기'],
      'isExpanded': true,
    },
    {
      'title': '학원 다녀오기',
      'smallTasks': [],
      'isExpanded': false,
    },
    {
      'title': '잘 준비하기',
      'smallTasks': [],
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.onBack?.call(),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '미션 관리',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'JejuGothic',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: WeekCalendarWidget(
                selectedDay: selectedDay,
                isFullCalendarOpen: isFullCalendarOpen,
                onDaySelected: (day) => setState(() => selectedDay = day),
                onToggleCalendar: () => setState(() => isFullCalendarOpen = !isFullCalendarOpen),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                '오늘의 퀘스트!',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'JejuGothic',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                mission['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'JejuGothic',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => missions.removeAt(index));
                                },
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mission['isExpanded'] == true && mission['smallTasks'].isNotEmpty)
                          ...List<String>.from(mission['smallTasks']).map((task) =>
                              Container(
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'JejuGothic',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                          ).toList(),
                        if (mission['smallTasks'].isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                missions[index]['isExpanded'] = !(mission['isExpanded'] as bool);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Center(
                                child: Icon(
                                  mission['isExpanded'] == true
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFFBCBCBC),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}