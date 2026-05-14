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

    // 경험치 관련 (서버 데이터가 null이면 0으로 처리)
    int currentExp = info?.currentExp ?? 0;
    int maxExp = 1000; // 레벨업 기준 (기획에 맞게 수정 가능)

    // 게이지 비율 (0.0 ~ 1.0)
    double expFactor = (currentExp / maxExp).clamp(0.0, 1.0);
    // 표시용 퍼센트 (정수)
    int expPercent = (expFactor * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 상단 파란 영역
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
                        const Text(
                          '프로필',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) Navigator.pushReplacementNamed(context, '/start');
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF75E5E),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '로그아웃',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 프로필 카드
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE1F5FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFF1586E2), size: 40),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname,
                                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '레벨 $level - 모험가',
                                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ✅ 수정된 경험치 바 디자인 (요청하신 이미지 반영)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // 배경 바 (연회색)
                                Container(
                                  width: double.infinity,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E2E2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                // 실제 경험치 바 (연두색)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: constraints.maxWidth * expFactor,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA1FF6F), // 사진 속 연두색
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        // ✅ 수정된 경험치 텍스트 (다음 레벨까지 % 표시)
                        Text(
                          '다음 레벨까지 $expPercent%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          '예상 직업: 마법사',
                          style: TextStyle(color: Color(0xFF1586E2), fontSize: 16, fontWeight: FontWeight.bold),
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
                  const _StatCard(value: '47', label: '완료한 퀘스트'),
                  const SizedBox(width: 12),
                  _StatCard(value: '$gold', label: '보유한 골드'),
                  const SizedBox(width: 12),
                  const _StatCard(value: '5일', label: '연속 달성'),
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
                  _AchievementCard(title: '일주일 달성'),
                  _AchievementCard(title: '백만장자'),
                  _AchievementCard(title: '전설의 시작'),
                  _AchievementCard(title: '한 달 달성', disabled: true),
                  _AchievementCard(title: '위대한 모험', disabled: true),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: SizedBox(
                  width: 290,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => showDialog(context: context, builder: (context) => const ParentLink()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1586E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('보호자 연동하기', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
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