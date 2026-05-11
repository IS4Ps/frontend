import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/token_manager.dart';
import 'package:frontend/view_model/profile/profile_view_model.dart'; // 뷰모델 임포트
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
    // 화면에 진입할 때 서버 데이터를 새로 고칩니다.
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('selectedChildId');
    final token = TokenManager().token ?? "";

    if (childId != null && mounted) {
      // ProfileViewModel을 통해 서버 데이터 호출
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      await profileVM.fetchChildInformation(childId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // ProfileViewModel의 상태를 구독합니다.
    final profileVM = Provider.of<ProfileViewModel>(context);
    final info = profileVM.childInfo;

    // 서버 데이터 매핑 (데이터가 없으면 기본값 표시)
    String nickname = info?.nickname ?? "이름 없음";
    int level = info?.level ?? 1;
    int gold = info?.gold ?? 0;
    int currentExp = info?.currentExp ?? 0;

    // 경험치 퍼센트 계산 (예시: 1000이 만점일 때)
    double expPercent = (currentExp / 1000).clamp(0.0, 1.0);

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
                        // 로그아웃 버튼 (데이터 삭제 로직 추가 가능)
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

                  // 프로필 카드 (실제 데이터 반영)
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
                                  nickname, // ★ 실제 닉네임
                                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '레벨 $level - 모험가', // ★ 실제 레벨
                                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 경험치 바
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E2E2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: constraints.maxWidth * expPercent,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA1FF6F),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        Text(
                          '경험치: $currentExp / 1000', // ★ 실제 경험치
                          style: const TextStyle(color: Colors.black, fontSize: 14),
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

            // 통계 카드 (골드 데이터 반영)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const _StatCard(value: '47', label: '완료한 퀘스트'),
                  const SizedBox(width: 12),
                  _StatCard(value: '$gold', label: '보유한 골드'), // ★ 실제 골드
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

            // 업적 그리드 (생략 가능)
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

            // 보호자 연동 버튼
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

// 하단 보조 위젯들은 기존과 동일하게 유지하되 디자인 살짝 정돈
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