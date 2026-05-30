import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_model/dashboard/dashboard_view_model.dart';
import '../../view_model/profile/profile_view_model.dart';
import '../../models/dashboard/monthly_mood_model.dart';
import 'heatmap_card.dart';
import 'minigame_score_card.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  const DashboardScreen({super.key, this.onNotificationTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final dashboardVM = context.read<DashboardViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final prefs = await SharedPreferences.getInstance();

    String? savedChildId = prefs.getString('selectedChildId');
    String? deviceId = prefs.getString('lastConnectedDeviceId') ?? "device-001";

    if (savedChildId != null) {
      debugPrint('[Dashboard] 데이터 동기화 시작 (ID: $savedChildId)');

      // 1. 프로필 정보(닉네임 등) 로드
      await profileVM.fetchChildInformation(savedChildId, deviceId);

      // 2. 대시보드 통계 및 감정 캘린더 로드
      await dashboardVM.fetchMonthlyMood();
      await dashboardVM.fetchWeeklyStats();
      await dashboardVM.fetchRoutineHeatmap();
      await dashboardVM.fetchAllMinigameLogs();
    } else {
      debugPrint('[Dashboard] 저장된 아이 ID가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVM = context.watch<DashboardViewModel>();
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F7),
      body: RefreshIndicator(
        // ✅ 위로 당겨서 새로고침 기능 추가
        onRefresh: _loadDashboardData,
        child: dashboardVM.isLoading || profileVM.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: _buildHeader(profileVM),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                // RefreshIndicator 작동을 위해 항상 스크롤 가능하도록 설정
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    _buildProgressCard(dashboardVM),
                    const SizedBox(height: 24),
                    _buildActivityCard(),
                    const SizedBox(height: 24),
                    _buildEmotionCard(dashboardVM.monthlyMoodData),
                    const SizedBox(height: 24),
                    HeatmapCard(
                      title: '루틴 습관 히트맵',
                      subtitle: '3개월 일관성',
                      data: dashboardVM.routineHeatmapData.isEmpty
                          ? List.filled(91, 0)
                          : dashboardVM.routineHeatmapData,
                    ),
                    const SizedBox(height: 24),
                    const HeatmapCard(
                      title: '미니게임 히트맵',
                      subtitle: '3개월 일관성',
                      data: [2,1,0,2,3,3,0,1,1,0,2,3,2, 2,2,2,0,3,2,1,2,1,0,0,2,3, 1,3,2,0,0,3,1,2,2,2,2,3,1, 2,1,0,2,2,0,0,2,2,0,3,2,2, 2,3,0,3,2,3,0,2,3,1,3,2,3, 3,2,2,0,1,3,3,1,0,1,3,0,0, 3,2,2,3,0,3,0,1,0,1,2,2,2],
                    ),
                    const SizedBox(height: 24),
                    const MinigameScoreCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 닉네임 동적 반영 헤더
  Widget _buildHeader(ProfileViewModel profileVM) {
    final String nickname = profileVM.childInfo?.nickname ?? "아이";

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD7D7D7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nickname의 진행 상황',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                '진행 상황을 한 눈에 볼 수 있는 대시보드',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => widget.onNotificationTap?.call(),
              child: Stack(
                clipBehavior: Clip.none,
                children: const [
                  Icon(Icons.notifications_none, size: 34),
                  Positioned(
                    right: -2,
                    top: 18,
                    child: Text('④', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DashboardViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('활동 & 성과', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('주간 루틴 완료율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 190,
              height: 180,
              child: CustomPaint(
                painter: DonutChartPainter(progress: viewModel.avgCompletionRate / 100),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${viewModel.avgCompletionRate.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text('평균', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('활동 태그 비율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 180,
              height: 170,
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

  Widget _buildEmotionCard(MonthlyMoodModel? moodData) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16), // 하단 패딩 조정
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('감정 캘린더', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          _buildCalendarSection(moodData),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('상위 3개 감정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TopEmotionItem(emoji: '😆', label: '행복'),
              _TopEmotionItem(emoji: '😊', label: '신남'),
              _TopEmotionItem(emoji: '😐', label: '평온'),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text('감정 변동성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                const SizedBox(
                  width: 42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('높음', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('중간', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('낮음', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 100),
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

  // ✅ 감정 데이터를 날짜에 맞게 매핑하도록 수정
  Widget _buildCalendarSection(MonthlyMoodModel? moodData) {
    final now = DateTime.now();
    final int year = moodData?.year ?? now.year;
    final int month = moodData?.month ?? now.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: daysInMonth,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.7, // 높이 조절
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final int day = index + 1;
        // 서버 형식에 맞춘 날짜 키 생성 (예: 2026-05-12)
        final String dateKey = "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

        final log = moodData?.moodMap[dateKey];
        final bool hasEmoji = log != null && log.emotionEmoji.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: !hasEmoji ? const Color(0xFFF5F5F5) : Colors.white,
            border: Border.all(color: hasEmoji ? const Color(0xFF1586E2).withOpacity(0.4) : const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  color: !hasEmoji ? Colors.grey : Colors.black,
                  fontWeight: hasEmoji ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasEmoji ? log.emotionEmoji : '',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ... Painter 및 하위 위젯들은 기존과 동일 (생략 가능하나 유지)
class _TopEmotionItem extends StatelessWidget {
  final String emoji;
  final String label;
  const _TopEmotionItem({required this.emoji, required this.label});
  @override Widget build(BuildContext context) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }
}

class DonutChartPainter extends CustomPainter {
  final double progress;
  const DonutChartPainter({required this.progress});
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final trackPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 16.0..color = const Color(0xFFD7D7D7);
    final progressPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 16.0..strokeCap = StrokeCap.round..color = const Color(0xFF1586E2);
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, progressPaint);
  }
  @override bool shouldRepaint(covariant DonutChartPainter oldDelegate) => oldDelegate.progress != progress;
}

class PieSection { final double value; final Color color; final String label; const PieSection({required this.value, required this.color, required this.label}); }

class PieChartPainter extends CustomPainter {
  final List<PieSection> sections;
  const PieChartPainter({required this.sections});
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = pi / 2;
    for (final section in sections) {
      final sweepAngle = 2 * pi * section.value;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, Paint()..color = section.color);
      startAngle += sweepAngle;
    }
  }
  @override bool shouldRepaint(covariant PieChartPainter oldDelegate) => true;
}

class EmotionLineChartPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = const Color(0xFF1586E2)..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.1, size.width * 0.6, size.height * 0.5);
    path.cubicTo(size.width * 0.8, size.height * 0.8, size.width * 0.9, size.height * 0.2, size.width, size.height * 0.4);
    canvas.drawPath(path, linePaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}