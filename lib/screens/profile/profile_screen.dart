import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart';
import 'package:frontend/view_model/profile/profile_view_model.dart';
import 'package:frontend/screens/profile/parent_link.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('selectedChildId');
    final deviceId = prefs.getString('lastConnectedDeviceId') ?? "device-001";

    if (childId != null && mounted) {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      await profileVM.fetchChildInformation(childId, deviceId);
      await profileVM.fetchAvailableJobs();
      await profileVM.fetchMonthlyStats(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final profileVM = Provider.of<ProfileViewModel>(context);
    final info = profileVM.childInfo;

    // --- 데이터 매핑 및 계산 로직 ---
    String nickname = info?.nickname ?? "이름 없음";
    int level = info?.level ?? 1;
    int gold = info?.gold ?? 0;

    // 🚀 [핵심 수정]: 화면 단의 꼬이기 쉬운 스탯 수치 비교 조건문을 완전히 걷어냅니다.
    // 대신, 뷰모델이 서버 스탯을 파싱하여 안전하게 들고 있는 selectedJobId를 직접 매핑합니다.
    String jobTitle = "모험가";
    if (profileVM.selectedJobId != null) {
      if (profileVM.selectedJobId == 1) jobTitle = "전사";
      else if (profileVM.selectedJobId == 2) jobTitle = "마법사";
      else if (profileVM.selectedJobId == 3) jobTitle = "예술가";
    }

    int currentExp = info?.currentExp ?? 0;
    int maxExp = 1000;
    double expFactor = (currentExp / maxExp).clamp(0.0, 1.0);
    int expPercent = (expFactor * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: topPadding),
              color: const Color(0xFF1586E2),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('프로필', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) Navigator.pushReplacementNamed(context, '/start');
                          },
                          child: Container(
                            width: 100, height: 30,
                            decoration: BoxDecoration(color: const Color(0xFFF75E5E), borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 프로필 카드
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: Color(0xFFE1F5FE), shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Color(0xFF1586E2), size: 40),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nickname, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                // 🚀 동적 jobTitle 변수를 사용해 '레벨 1 - 예술가' 형태로 정상 노출됩니다.
                                Text('레벨 $level - $jobTitle', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  width: double.infinity, height: 18,
                                  decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(30)),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: constraints.maxWidth * expFactor,
                                  height: 18,
                                  decoration: BoxDecoration(color: const Color(0xFFA1FF6F), borderRadius: BorderRadius.circular(30)),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text('다음 레벨까지 $expPercent%', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 18),

                        // 🚀 하단 요약 타이틀 영역도 동적 연동 완료
                        Text(
                          jobTitle == "모험가" ? '현재 직업: 없음 (모험가)' : '현재 직업: $jobTitle',
                          style: const TextStyle(color: Color(0xFF1586E2), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 통계 카드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(value: '${profileVM.completedQuestCount}', label: '완료한 퀘스트'),
                  const SizedBox(width: 12),
                  _StatCard(value: '$gold', label: '보유한 골드'),
                  const SizedBox(width: 12),
                  _StatCard(value: '${profileVM.streakDays}일', label: '연속 달성'),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('업적', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
                children: const [
                  _AchievementCard(title: '첫 퀘스트 완료'),
                  _AchievementCard(title: '일주일 달성', disabled: true),
                  _AchievementCard(title: '백만장자', disabled: true),
                  _AchievementCard(title: '전설의 시작', disabled: true),
                  _AchievementCard(title: '한 달 달성', disabled: true),
                  _AchievementCard(title: '위대한 모험', disabled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final bool disabled;
  const _AchievementCard({required this.title, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: disabled ? const Color(0xFFF1F1F1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: disabled ? Colors.grey : Colors.orange, size: 30),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ],
      ),
    );
  }
}