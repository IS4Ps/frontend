import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../start_screen.dart';
import '../../view_model/setting/setting_view_model.dart';
import '../../view_model/profile/profile_view_model.dart';
import '../../auth/token_manager.dart' as my_auth;
import 'child_selection_dialog.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String currentChildName = '준수';
  String? profileImageUrl;
  String parentNickname = '사용자';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserInfo();
      _loadKakaoProfile();
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      if (mounted) {
        await context.read<SettingViewModel>().fetchParentInfo();
      }
    } catch (e) {
      debugPrint('로드 에러: $e');
    }
  }

  Future<void> _loadKakaoProfile() async {
    try {
      User user = await UserApi.instance.me();
      setState(() {
        parentNickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
        profileImageUrl = user.kakaoAccount?.profile?.thumbnailImageUrl;
      });
    } catch (e) {
      debugPrint('카카오 프로필 로드 실패: $e');
    }
  }

  // --- 자녀 등록 이름 입력 팝업 ---
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
          decoration: const InputDecoration(
            hintText: '자녀의 닉네임을 입력하세요',
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1687E3))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await _registerChildAction(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1687E3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- [수정] 자녀 등록 및 QR 토큰 발급 로직 ---
  Future<void> _registerChildAction(String nickname) async {
    final profileVM = context.read<ProfileViewModel>();

    // 1. 프로필 생성
    bool success = await profileVM.createChildProfile(
      nickname: nickname,
      deviceId: "device-001",
    );

    if (success && mounted) {
      // 2. 연동용 linkToken 발급 (서버 명세 반영)
      final int? newChildId = profileVM.lastCreatedChildId;
      if (newChildId != null) {
        String? linkToken = await profileVM.fetchLinkToken(newChildId);

        if (linkToken != null && mounted) {
          // 3. 인자 3개 전달 (토큰, 닉네임, 아이디)
          _showQRCodeDialog(linkToken, nickname, newChildId.toString());
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이 등록에 실패했습니다.')),
      );
    }
  }

  // --- [수정] QR 코드 팝업 (인자 3개 정의) ---
  // SettingScreen.dart 내부 _showQRCodeDialog 함수 수정

  void _showQRCodeDialog(String linkToken, String nickname, String childId) {
    // ✅ 현재 부모의 실제 토큰을 가져옵니다.
    final String parentToken = my_auth.TokenManager().parentToken ?? "";

    // ✅ QR 데이터에 "링크토큰,부모토큰" 형태로 묶어서 넣습니다.
    final String combinedData = "$linkToken,$parentToken";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('연결 준비 완료!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text('\'$nickname\' 어린이의 기기에서\n아래 QR 코드를 스캔해 주세요.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF7C7D7D))),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1687E3), width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: QrImageView(
                  data: combinedData, // ✅ linkToken 대신 combinedData 사용
                  version: QrVersions.auto,
                  size: 180.0,
                ),
              ),
              const SizedBox(height: 20),
              Text('ID: $childId',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1687E3))
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _openChildSelection() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ChildSelectionDialog(),
    ).then((value) {
      if (value != null) setState(() => currentChildName = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingVM = context.watch<SettingViewModel>();
    final profileVM = context.watch<ProfileViewModel>();

    bool isLoading = settingVM.isLoading || profileVM.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
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
        ],
      ),
    );
  }

  Widget _buildChildAccountSection(ProfileViewModel profileVM) {
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
                const CircleAvatar(radius: 24, backgroundColor: Color(0XFFD9D9D9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentChildName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      const Text('레벨 1 - 모험가', style: TextStyle(fontSize: 12, color: Color(0XFF7C7D7D))),
                    ],
                  ),
                ),
                // --- [수정] 다시보기 시에도 새 토큰을 받아오도록 설정 ---
                if (profileVM.lastCreatedChildId != null)
                  IconButton(
                    onPressed: () async {
                      String? linkToken = await profileVM.fetchLinkToken(profileVM.lastCreatedChildId!);
                      if (linkToken != null && mounted) {
                        _showQRCodeDialog(linkToken, currentChildName, profileVM.lastCreatedChildId.toString());
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

  // --- 기존 헬퍼 위젯들 ---
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

  Widget _buildMenuSection() {
    return _buildSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildListMenu('도움말 및 지원'),
          const Divider(height: 1),
          _buildListMenu('서비스 이용약관'),
          const Divider(height: 1),
          _buildListMenu('개인정보 처리방침'),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextButton(
        onPressed: _handleLogout,
        style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5E6E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(onPressed: () async {
            await UserApi.instance.logout();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const StartScreen()), (route) => false);
          }, child: const Text('확인', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() { return Container(width: double.infinity, padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)), Text('부모님 계정 관리', style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 12))])); }
  Widget _buildSectionCard({String? title, Widget? trailing, required Widget child, EdgeInsets? padding}) { return Container(margin: const EdgeInsets.only(bottom: 15), padding: padding ?? const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), if (trailing != null) trailing])), child])); }
  Widget _buildListMenu(String title) { return ListTile(dense: true, title: Text(title, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: () {}); }
}