import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR 패키지 추가
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../start_screen.dart';
import '../../view_model/setting/setting_view_model.dart';
import '../../view_model/profile/profile_view_model.dart';
import '../../view_model/reward/reward_view_model.dart';
import '../../view_model/dashboard/dashboard_view_model.dart';
import '../../auth/token_manager.dart' as my_auth;
import 'child_selection_dialog.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String currentChildName = '이름 없음';
  String? profileImageUrl;
  String parentNickname = '사용자';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _handleRefresh();
    });
  }

  Future<void> _handleRefresh() async {
    try {
      await Future.wait([
        context.read<SettingViewModel>().fetchParentInfo(),
        _loadKakaoProfile(),
      ]);

      final prefs = await SharedPreferences.getInstance();
      String? savedName = prefs.getString('selectedChildName');
      String? savedId = prefs.getString('selectedChildId');

      if (savedName != null && mounted) {
        setState(() => currentChildName = savedName);
      }

      if (savedId != null && mounted) {
        await context.read<ProfileViewModel>().fetchChildInformation(savedId, "device-001");
        if (mounted) {
          context.read<RewardViewModel>().fetchOfflineRewards();
          context.read<DashboardViewModel>().fetchMonthlyMood();
        }
      }
    } catch (e) {
      debugPrint('새로고침 에러: $e');
    }
  }

  Future<void> _loadKakaoProfile() async {
    try {
      User user = await UserApi.instance.me();
      if (mounted) {
        setState(() {
          parentNickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
          profileImageUrl = user.kakaoAccount?.profile?.thumbnailImageUrl;
        });
      }
    } catch (e) {
      debugPrint('카카오 프로필 로드 실패: $e');
    }
  }

  Future<void> _updateSelectedChild(int id, String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await my_auth.TokenManager().setSelectedChildId(id);
    await prefs.setString('selectedChildName', nickname);
    await prefs.setString('selectedChildId', id.toString());

    if (!mounted) return;
    await context.read<ProfileViewModel>().fetchChildInformation(id.toString(), "device-001");

    if (mounted) {
      setState(() => currentChildName = nickname);
      context.read<RewardViewModel>().fetchOfflineRewards();
      context.read<DashboardViewModel>().fetchMonthlyMood();
    }
  }

  void _showAddChildDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('자녀 등록', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '자녀의 닉네임을 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await _registerChildAction(name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1687E3)),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _registerChildAction(String nickname) async {
    final profileVM = context.read<ProfileViewModel>();
    
    // ✅ [FCM 토큰 추출] 가짜 ID 대신 진짜 토큰을 가져옵니다.
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String deviceId = fcmToken ?? "parent_device_${DateTime.now().millisecondsSinceEpoch}";
    debugPrint('🚀 발급된 부모 FCM 토큰: $deviceId');

    bool success = await profileVM.createChildProfile(nickname: nickname, deviceId: deviceId);

    if (success && mounted) {
      final int? newChildId = profileVM.lastCreatedChildId;
      if (newChildId != null) {
        await _updateSelectedChild(newChildId, nickname);
        String? linkToken = await profileVM.fetchLinkToken(newChildId);
        if (linkToken != null && mounted) {
          _showQRCodeDialog(linkToken, nickname, newChildId.toString());
        }
      }
    }
  }

  void _openChildSelection() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ChildSelectionDialog(),
    ).then((selectedChild) async {
      if (selectedChild != null && mounted) {
        await _updateSelectedChild(selectedChild.id, selectedChild.nickname);
      }
    });
  }

  // ✅ QR 코드 다이얼로그 레이아웃 최적화 (SizedBox로 크기 명시)
  void _showQRCodeDialog(String linkToken, String nickname, String childId) {
    final String parentToken = my_auth.TokenManager().parentToken ?? "";
    final String combinedData = "$linkToken,$parentToken";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞춤
          children: [
            const Text('연결 준비 완료!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text('\'$nickname\' 기기에서 스캔하세요.', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            // ✅ SizedBox를 추가하여 QR 코드가 그려질 공간을 확실히 확보합니다.
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: combinedData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text('ID: $childId', style: const TextStyle(color: Color(0xFF1687E3), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingVM = context.watch<SettingViewModel>();
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: const Color(0xFF1687E3),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: (settingVM.isLoading || profileVM.isLoading)
                    ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                    : Column(
                  children: [
                    _buildProfileSection(settingVM),
                    _buildChildAccountSection(profileVM),
                    _buildMenuSection(),
                    const SizedBox(height: 10),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildAccountSection(ProfileViewModel profileVM) {
    final String level = profileVM.childInfo?.level?.toString() ?? '1';
    final int? currentChildId = profileVM.childInfo?.childId;

    // 🚀 [동적 직업 매핑]: ProfileScreen과 완전히 동일하게 selectedJobId를 반영합니다.
    String jobTitle = "모험가";
    if (profileVM.selectedJobId != null) {
      if (profileVM.selectedJobId == 1) jobTitle = "전사";
      else if (profileVM.selectedJobId == 2) jobTitle = "마법사";
      else if (profileVM.selectedJobId == 3) jobTitle = "예술가";
    }

    return _buildSectionCard(
      title: '자녀 계정',
      trailing: TextButton(
        onPressed: _openChildSelection,
        child: const Text('선택하기', style: TextStyle(color: Color(0XFF1687E3), fontWeight: FontWeight.bold)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                // 🔄 [교체 포인트]: 밋밋했던 CircleAvatar를 원하셨던 ProfileScreen의 예쁜 컨테이너 구조로 완벽 교체!
                Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: Color(0xFFE1F5FE), shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Color(0xFF1586E2), size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentChildName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      // 🚀 고정된 '모험가' 대신 동적 jobTitle 변수를 적용해 싱크를 맞춥니다.
                      Text('레벨 $level - $jobTitle', style: const TextStyle(fontSize: 12, color: Color(0XFF7C7D7D))),
                    ],
                  ),
                ),
                if (currentChildId != null)
                  IconButton(
                    onPressed: () async {
                      String? linkToken = await profileVM.fetchLinkToken(currentChildId);
                      if (linkToken != null && mounted) {
                        _showQRCodeDialog(linkToken, currentChildName, currentChildId.toString());
                      }
                    },
                    icon: const Icon(Icons.qr_code, color: Color(0XFF1687E3), size: 24),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showAddChildDialog,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('자녀 계정 연동하기', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1687E3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await UserApi.instance.logout();
    await my_auth.TokenManager().clear();
    await prefs.remove('selectedChildName');
    await prefs.remove('selectedChildId');
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const StartScreen()), (route) => false);
  }

  Widget _buildProfileSection(SettingViewModel viewModel) {
    final parentData = viewModel.parentData;
    return _buildSectionCard(
      title: '프로필',
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
            child: profileImageUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(parentNickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              Text(parentData?.email ?? '이메일 정보 없음', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuSection() { return _buildSectionCard(padding: EdgeInsets.zero, child: Column(children: [_buildListMenu('도움말 및 지원'), const Divider(height: 1), _buildListMenu('서비스 이용약관'), const Divider(height: 1), _buildListMenu('개인정보 처리방침')])); }
  Widget _buildLogoutButton() { return SizedBox(width: double.infinity, height: 46, child: TextButton(onPressed: _handleLogout, style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5E6E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))); }
  Widget _buildCustomAppBar() { return Container(width: double.infinity, padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)), Text('부모님 계정 관리', style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 12))])); }
  Widget _buildSectionCard({String? title, Widget? trailing, required Widget child, EdgeInsets? padding}) { return Container(margin: const EdgeInsets.only(bottom: 15), padding: padding ?? const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), if (trailing != null) trailing])), child])); }
  Widget _buildListMenu(String title) { return ListTile(dense: true, title: Text(title, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: () {}); }
}