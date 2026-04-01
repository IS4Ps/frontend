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

          const SizedBox(height: 25),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 25),
                  _buildActivityCard(),
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
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD7D7D7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('준수의 진행 상황',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('진행 상황을 한 눈에 볼 수 있는 대시보드',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: const [
                Icon(Icons.notifications_none, size: 35),
                Positioned(
                  right: 0,
                  top: 19,
                  child: Text('④',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 카드 1: 진행률 도넛 차트 (CustomPainter) =====
  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: const Text('활동 & 성과',
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: const Text('주간 루틴 완료율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
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
                      Text('85%',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('평균',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('+3% 추세',
                style: TextStyle(color: Color(0xFF53C516))),
          ),
        ],
      ),
    );
  }

  // ===== 카드 2: 파이 차트 (CustomPainter) =====
  Widget _buildActivityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: const Text('활동 태그 비율', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: SizedBox(
              width: 170,
              height: 160,
              child: CustomPaint(
                painter: PieChartPainter(
                  sections: const [
                    PieSection(value: 0.53, color: Color(0xFFE05555), label: '운동'),
                    PieSection(value: 0.13, color: Color(0xFF1586E2), label: '예술'),
                    PieSection(value: 0.34, color: Color(0xFF4CAF50), label: '공부'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────
// 도넛 차트 Painter
// ───────────────────────────────────────────
class DonutChartPainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0

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

    // 배경 트랙
    canvas.drawCircle(center, radius, trackPaint);

    // 진행률 호 (-90도 시작, 시계방향)
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) =>
      old.progress != progress;
}

// ───────────────────────────────────────────
// 파이 차트 Painter
// ───────────────────────────────────────────
class PieSection {
  final double value; // 0.0 ~ 1.0 (비율)
  final Color color;
  final String label;

  const PieSection(
      {required this.value, required this.color, required this.label});
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

      // 라벨 (퍼센트 텍스트)
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

      // 예술만 살짝 더 오른쪽 + 위로(미세조정)
      if (section.label == '예술') {
        adjustedOffset += const Offset(5, -10);
      }

      tp.paint(canvas, adjustedOffset);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) =>
      old.sections != sections;
}