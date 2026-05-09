import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 SDK 임포트
import '../../start_screen.dart'; // StartScreen 경로 확인 필수!
import 'child_selection_dialog.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String currentChildName = '준수';
  String parentNickname = '준수철수맘';

  void _openChildSelection() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ChildSelectionDialog(),
    ).then((value) {
      if (value != null) {
        setState(() {
          currentChildName = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildProfileSection(),
                  _buildChildAccountSection(),
                  _buildMenuSection(),
                  const SizedBox(height: 10),
                  _buildLogoutButton(), // 로그아웃 버튼
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 프로필 섹션 위젯 ---
  Widget _buildProfileSection() {
    return _buildSectionCard(
      title: '프로필',
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Color(0XFFD9D9D9)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parentNickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  const Text('susumom@example.com', style: TextStyle(fontSize: 12, color: Color(0XFF7C7D7D))),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(currentNickname: parentNickname),
                  ),
                ).then((value) {
                  if (value != null) setState(() => parentNickname = value);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9D9),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('프로필 수정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          )
        ],
      ),
    );
  }

  // --- 자녀 계정 섹션 위젯 ---
  Widget _buildChildAccountSection() {
    return _buildSectionCard(
      title: '자녀 계정',
      trailing: TextButton(
        onPressed: _openChildSelection,
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 20)),
        child: const Text('선택하기', style: TextStyle(color: Color(0XFF1687E3), fontSize: 13, fontWeight: FontWeight.bold)),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentChildName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    const Text('레벨 1 - 모험가', style: TextStyle(fontSize: 12, color: Color(0XFF7C7D7D))),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.link, size: 20),
              label: const Text('자녀 계정 연동하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1687E3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- 메뉴 리스트 섹션 ---
  Widget _buildMenuSection() {
    return _buildSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildListMenu('도움말 및 지원'),
          const Divider(height: 1, indent: 15, endIndent: 15),
          _buildListMenu('서비스 이용약관'),
          const Divider(height: 1, indent: 15, endIndent: 15),
          _buildListMenu('개인정보 처리방침'),
        ],
      ),
    );
  }

  // --- 로그아웃 버튼 (핵심 로직 적용) ---
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('정말 로그아웃하시겠습니까?\n로그인 정보가 완전히 삭제됩니다.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
                TextButton(
                  onPressed: () async {
                    try {
                      // 1. 카카오 공식 로그아웃
                      await UserApi.instance.logout();

                      // 2. [핵심] 기기 내 토큰 물리적 완전 삭제
                      await TokenManagerProvider.instance.manager.clear();

                      debugPrint('로컬 토큰이 완전히 삭제되었습니다.');

                      if (mounted) {
                        // 3. 다시 시작 화면으로 보내면서 모든 이전 화면 기록 삭제
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const StartScreen()),
                              (route) => false,
                        );
                      }
                    } catch (e) {
                      // 에러가 나더라도 무조건 토큰은 지우고 화면을 이동시켜야 안전합니다.
                      await TokenManagerProvider.instance.manager.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const StartScreen()),
                            (route) => false,
                      );
                    }
                  },
                  child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF5E6E6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.redAccent, size: 16),
            SizedBox(width: 8),
            Text('로그아웃', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // --- 공통 레이아웃 위젯 ---
  Widget _buildCustomAppBar() { return Container(width: double.infinity, padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)), Text('부모님 계정 관리', style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 12))])); }
  Widget _buildSectionCard({String? title, Widget? trailing, required Widget child, EdgeInsets? padding}) { return Container(margin: const EdgeInsets.only(bottom: 15), padding: padding ?? const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), if (trailing != null) trailing])), child])); }
  Widget _buildListMenu(String title) { return ListTile(dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 20), title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20), onTap: () {}); }
}

// EditProfileScreen 클래스는 기존과 동일하게 유지...
class EditProfileScreen extends StatefulWidget {
  final String currentNickname;
  const EditProfileScreen({super.key, required this.currentNickname});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nicknameController;
  final TextEditingController _emailController = TextEditingController(text: 'susumom@example.com');

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('프로필 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, size: 60, color: Colors.white)),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF1687E3), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInputField(label: '닉네임', controller: _nicknameController),
            const SizedBox(height: 20),
            _buildInputField(label: '이메일', controller: _emailController, isReadOnly: true),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _nicknameController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1687E3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('저장하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF0F0F0) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1687E3), width: 1.5)),
          ),
        ),
      ],
    );
  }
}