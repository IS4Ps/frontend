import 'package:flutter/material.dart';

/// 주간 달력 위젯 (날짜 선택)
class WeekCalendarWidget extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final bool isFullCalendarOpen;
  final VoidCallback? onToggleCalendar;

  const WeekCalendarWidget({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.isFullCalendarOpen = false,
    this.onToggleCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (onToggleCalendar != null)
                GestureDetector(
                  onTap: onToggleCalendar,
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 1),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(28),
            ),
            child: isFullCalendarOpen
                ? _buildFullCalendar()
                : _buildWeekRow(),
          ),
        ],
      ),
    );
  }

  /// 첫 주 (1~7일) 요일 헤더 + 날짜
  Widget _buildWeekRow() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        7,
            (i) => Expanded(  // ✅ Flexible 대신 Expanded 사용 (균등 분할)
          child: _CalendarCell(
            dayLabel: days[i],
            date: i + 1,
            isSelected: selectedDay == i + 1,
            onTap: onDaySelected,
          ),
        ),
      ),
    );
  }

  /// 전체 달력 (1~28일)
  Widget _buildFullCalendar() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Column(
      children: [
        // 첫 번째 주: 요일 라벨 + 1~7
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            7,
                (i) => Expanded(  // ✅ 추가
              child: _CalendarCell(
                dayLabel: days[i],
                date: i + 1,
                isSelected: selectedDay == i + 1,
                onTap: onDaySelected,
              ),
            ),
          ),
        ),
        // 나머지 주: 8~28
        ...[
          [8, 9, 10, 11, 12, 13, 14],
          [15, 16, 17, 18, 19, 20, 21],
          [22, 23, 24, 25, 26, 27, 28],
        ].map(
              (week) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: week
                  .map(
                    (date) => Expanded(  // ✅ 추가
                  child: _NumberCell(
                    date: date,
                    isSelected: selectedDay == date,
                    onTap: onDaySelected,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// 요일 라벨 + 날짜 셀 (첫 번째 줄)
class _CalendarCell extends StatelessWidget {
  final String dayLabel;
  final int date;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _CalendarCell({
    required this.dayLabel,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'JejuGothic',
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 0),
        _NumberCell(date: date, isSelected: isSelected, onTap: onTap),
      ],
    );
  }
}

/// 날짜 숫자 셀 (선택 시 파란 원)
class _NumberCell extends StatelessWidget {
  final int date;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NumberCell({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(date),
      child: AspectRatio(  // ✅ 고정 width 대신 AspectRatio 사용
        aspectRatio: 1,  // 정사각형 유지
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 34,  // ✅ 최대 크기 제한
            maxHeight: 34,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                FractionallySizedBox(  // ✅ 부모 크기의 비율로 조정
                  widthFactor: 0.88,  // 30/34 ≈ 0.88
                  heightFactor: 0.88,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF8EBBE4),
                      shape: BoxShape.circle,
                    ),
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
    );
  }
}