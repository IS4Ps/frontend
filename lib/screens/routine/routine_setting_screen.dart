import 'package:flutter/material.dart';

class RoutineSettingScreen extends StatefulWidget {
  const RoutineSettingScreen({super.key});

  @override
  State<RoutineSettingScreen> createState() => _RoutineSettingScreenState();
}

class _RoutineSettingScreenState extends State<RoutineSettingScreen> {
  bool isFullCalendarOpen = false;
  int selectedDay = 1;

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
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _topActionButton(
                                icon: Icons.ios_share,
                                text: '루틴 불러오기',
                                backgroundColor: const Color(0x7C1586E2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '2월 $selectedDay일',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'JejuGothic',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isFullCalendarOpen =
                                        !isFullCalendarOpen;
                                      });
                                    },
                                    child: Icon(
                                      isFullCalendarOpen
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: const Color(0xFFB0B0B0),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: isFullCalendarOpen
                                    ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildTopCalendarCell('일', 1),
                                        _buildTopCalendarCell('월', 2),
                                        _buildTopCalendarCell('화', 3),
                                        _buildTopCalendarCell('수', 4),
                                        _buildTopCalendarCell('목', 5),
                                        _buildTopCalendarCell('금', 6),
                                        _buildTopCalendarCell('토', 7),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberItem(8),
                                        _buildNumberItem(9),
                                        _buildNumberItem(10),
                                        _buildNumberItem(11),
                                        _buildNumberItem(12),
                                        _buildNumberItem(13),
                                        _buildNumberItem(14),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberItem(15),
                                        _buildNumberItem(16),
                                        _buildNumberItem(17),
                                        _buildNumberItem(18),
                                        _buildNumberItem(19),
                                        _buildNumberItem(20),
                                        _buildNumberItem(21),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildNumberItem(22),
                                        _buildNumberItem(23),
                                        _buildNumberItem(24),
                                        _buildNumberItem(25),
                                        _buildNumberItem(26),
                                        _buildNumberItem(27),
                                        _buildNumberItem(28),
                                      ],
                                    ),
                                  ],
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildTopCalendarCell('일', 1),
                                    _buildTopCalendarCell('월', 2),
                                    _buildTopCalendarCell('화', 3),
                                    _buildTopCalendarCell('수', 4),
                                    _buildTopCalendarCell('목', 5),
                                    _buildTopCalendarCell('금', 6),
                                    _buildTopCalendarCell('토', 7),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 65,
                              child: _timeBox('8:30'),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '~',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 65,
                              child: _timeBox('9:30'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '미션 제목',
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0x607C7D7D),
                            ),
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
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '태그 선택',
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
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            _TagChip(label: '운동'),
                            _TagChip(label: '공부'),
                            _TagChip(label: '생활'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildTopCalendarCell(String day, int date) {
    final bool isSelected = selectedDay == date;

    return SizedBox(
      width: 34,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'JejuGothic',
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = date;
              });
            },
            child: SizedBox(
              width: 34,
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isSelected)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8EBBE4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '$date',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'JejuGothic',
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberItem(int date) {
    final bool isSelected = selectedDay == date;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = date;
        });
      },
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF8EBBE4),
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              '$date',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'JejuGothic',
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _topActionButton({
  required IconData icon,
  required String text,
  required Color backgroundColor,
}) {
  return Container(
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