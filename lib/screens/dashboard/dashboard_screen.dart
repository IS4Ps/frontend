import 'dart:math';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F7),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: _buildHeader(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildActivityCard(),
                  const SizedBox(height: 24),
                  _buildEmotionCard(),
                  const SizedBox(height: 24),
                  _buildHeatmapCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFD7D7D7)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '준수의 진행 상황',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '진행 상황을 한 눈에 볼 수 있는 대시보드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: const [
                Icon(Icons.notifications_none, size: 34),
                Positioned(
                  right: -2,
                  top: 18,
                  child: Text(
                    '④',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '활동 & 성과',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '주간 루틴 완료율',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 190,
              height: 180,
              child: CustomPaint(
                painter: DonutChartPainter(progress: 0.85),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '85%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '평균',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              '+3% 추세',
              style: TextStyle(
                color: Color(0xFF53C516),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '활동 태그 비율',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 180,
              height: 170,
              child: CustomPaint(
                painter: PieChartPainter(
                  sections: const [
                    PieSection(
                      value: 0.53,
                      color: Color(0xFFE05555),
                      label: '운동',
                    ),
                    PieSection(
                      value: 0.13,
                      color: Color(0xFF1586E2),
                      label: '예술',
                    ),
                    PieSection(
                      value: 0.34,
                      color: Color(0xFF4CAF50),
                      label: '공부',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '감정 캘린더',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildCalendarSection(),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '상위 3개 감정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TopEmotionItem(emoji: '😃', label: '행복'),
              _TopEmotionItem(emoji: '😆', label: '신남'),
              _TopEmotionItem(emoji: '😌', label: '평온'),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              '감정 변동성',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                const SizedBox(
                  width: 42,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('높음', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text('중간', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text('낮음', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: EmotionLineChartPainter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final List<String> dates = [
      '1', '2', '3', '4', '5', '6', '7',
      '8', '9', '10', '11', '12', '13', '14',
      '15', '16', '17', '18', '19', '20', '21',
      '22', '23', '24', '25', '26', '27', '28',
    ];

    final List<String> emotions = [
      '', '😀', '☹️', '😡', '😌', '😆', '😆',
      '☹️', '😞', '😡', '😆', '😌', '😀', '😡',
      '😀', '😌', '😀', '☹️', '😣', '😡', '☹️',
      '😣', '😆', '😌', '', '', '', '',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: dates.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.65,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemBuilder: (context, index) {
          final bool isEmpty = emotions[index].isEmpty;

          return Container(
            decoration: BoxDecoration(
              color: isEmpty ? const Color(0xFFF0F0F0) : Colors.white,
              border: Border.all(color: const Color(0xFFE6E6E6)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dates[index],
                  style: TextStyle(
                    fontSize: 13,
                    color: (dates[index] == '25' || dates[index] == '26'|| dates[index] == '27' || dates[index] == '28')
                        ? Colors.black87
                        : isEmpty ? const Color(0xFFB8B8B8) : Colors.black87,
                    fontWeight: (index == 24 || index == 25) ? FontWeight.w500 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  emotions[index],
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopEmotionItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _TopEmotionItem({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 44),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double progress;

  const DonutChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 16.0;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFD7D7D7);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1586E2);

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius, trackPaint);

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PieSection {
  final double value;
  final Color color;
  final String label;

  const PieSection({
    required this.value,
    required this.color,
    required this.label,
  });
}

class PieChartPainter extends CustomPainter {
  final List<PieSection> sections;

  const PieChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = pi / 2;

    for (final section in sections) {
      final sweepAngle = 2 * pi * section.value;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = section.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.55;
      final labelOffset = Offset(
        center.dx + labelRadius * cos(labelAngle),
        center.dy + labelRadius * sin(labelAngle),
      );

      final text = '${section.label}\n${(section.value * 100).round()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      Offset adjustedOffset =
          labelOffset - Offset(tp.width / 2, tp.height / 2);

      if (section.label == '예술') {
        adjustedOffset += const Offset(5, -10);
      }

      tp.paint(canvas, adjustedOffset);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.sections != sections;
  }
}

class EmotionLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD1D1D1)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF1586E2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 4) + 8;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final path = Path();
    path.moveTo(0, size.height * 0.82);
    path.cubicTo(
      size.width * 0.12, size.height * 0.68,
      size.width * 0.22, size.height * 0.70,
      size.width * 0.34, size.height * 0.58,
    );
    path.cubicTo(
      size.width * 0.42, size.height * 0.32,
      size.width * 0.50, size.height * 0.62,
      size.width * 0.62, size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.72, size.height * 0.16,
      size.width * 0.82, size.height * 0.18,
      size.width,        size.height * 0.42,
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildHeatmapCard() {
  // 0: 없음, 1: 연한, 2: 중간, 3: 진한
  final List<int> data = [
    2,1,0,2,3,3,0,1,1,0,2,3,2,
    2,2,2,0,3,2,1,2,1,0,0,2,3,
    1,3,2,0,0,3,1,2,2,2,2,3,1,
    2,1,0,2,2,0,0,2,2,0,3,2,2,
    2,3,0,3,2,3,0,2,3,1,3,2,3,
    3,2,2,0,1,3,3,1,0,1,3,0,0,
    3,2,2,3,0,3,0,1,0,1,2,2,2,
  ];

  final colors = [
    const Color(0xFFF1F3F5), // 없음
    const Color(0xFFBDECC7), // 연한
    const Color(0xFF2ED573), // 중간
    const Color(0xFF138A36), // 진한
  ];

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: const Text(
            '루틴 습관 히트맵',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: const Text(
            '3개월 일관성',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF3D3D3D),
            ),
          ),
        ),
        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 13,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: colors[data[index]],
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), // 4 → 10
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('1월', style: TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
              SizedBox(width: 76),
              Text('2월', style: TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
              SizedBox(width: 60),
              Text('3월', style: TextStyle(fontSize: 12, color: Color(0xFF3D3D3D))),
            ],
          ),
        ),
      ],
    ),
  );
}