import 'package:flutter/material.dart';

class RoutineSettingScreen extends StatelessWidget {
  const RoutineSettingScreen({super.key});

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
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '루틴 & 미션 설정',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _topActionButton(
                              icon: Icons.save_outlined,
                              text: '반복 루틴 저장',
                              backgroundColor: const Color(0x90E047FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _topActionButton(
                              icon: Icons.ios_share,
                              text: '루틴 불러오기',
                              backgroundColor: const Color(0x7C1586E2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '날짜 선택',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '2월 1일',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'JejuGothic',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _DayItem(day: '일', date: '1'),
                                  _DayItem(day: '월', date: '2'),
                                  _DayItem(day: '화', date: '3'),
                                  _DayItem(day: '수', date: '4'),
                                  _DayItem(day: '목', date: '5'),
                                  _DayItem(day: '금', date: '6'),
                                  _DayItem(day: '토', date: '7'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        '시간 설정',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _timeBox('8:30')),
                          const SizedBox(width: 12),
                          Expanded(child: _timeBox('9:30')),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        '미션 제목',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0x607C7D7D)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '예: 책 1권 읽기',
                          style: TextStyle(
                            color: Color(0xFF7C7D7D),
                            fontSize: 16,
                            fontFamily: 'JejuGothic',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        '태그 선택',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _TagChip(label: '운동'),
                          _TagChip(label: '공부'),
                          _TagChip(label: '생활'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 59,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1586E2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '미션 저장하기 (1일 선택됨)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'JejuGothic',
                              fontWeight: FontWeight.w400,
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

  Widget _topActionButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
  }) {
    return Container(
      height: 46, // ✅ 크기 줄임
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
          fontSize: 16,
          fontFamily: 'JejuGothic',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String day;
  final String date;

  const _DayItem({required this.day, required this.date});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        '$day\n$date',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'JejuGothic',
          fontWeight: FontWeight.w400,
          height: 1.1,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
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
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}