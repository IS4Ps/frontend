import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/view_model/profile/profile_view_model.dart';
import 'package:frontend/view_model/store/store_view_model.dart';
import 'package:frontend/view_model/store/inventory_view_model.dart';
import 'package:frontend/view_model/quest/quest_view_model.dart';
import 'screens/quest/quest_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/store/store_screen.dart';

class ChildMainScreen extends StatefulWidget {
  const ChildMainScreen({super.key});

  @override
  State<ChildMainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<ChildMainScreen> {
  int _selectedIndex = 0;
  String? _savedChildId;

  @override
  void initState() {
    super.initState();
    _initAndFetchData();
  }

  Future<void> _initAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('selectedChildId');
    // 생성 시 저장된 deviceId가 없다면 기본값을 사용합니다.
    final deviceId = prefs.getString('lastConnectedDeviceId') ?? "test_device_id_001";

    if (childId != null && mounted) {
      setState(() => _savedChildId = childId);
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

      // 아동 로그인 -> 토큰 갱신 -> 정보 조회를 순차적으로 수행
      await profileVM.fetchChildInformation(childId, deviceId);

      if (mounted) {
        final questVM = Provider.of<QuestViewModel>(context, listen: false);
        questVM.loadTodayMood();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildHomeContent(String nickname) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FBFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 320,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                const Icon(Icons.face_retouching_natural_rounded, size: 80, color: Color(0xFF4A90E2)),
                const SizedBox(height: 20),
                Text("반가워요!\n$nickname님", textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333), height: 1.3)),
                const SizedBox(height: 12),
                Text("ID: $_savedChildId", style: const TextStyle(fontSize: 14, color: Color(0xFF7C7D7D), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    String nickname = profileVM.childInfo?.nickname ?? "로딩 중...";

    final List<Widget> _screens = [
      _buildHomeContent(nickname),
      const QuestScreen(),
      const ProfileScreen(),
      const StoreScreen(),
    ];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoreViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE3E3E3), width: 1.0)),
      ),
      child: Theme(
        data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF4A90E2),
          unselectedItemColor: const Color(0xFF7C7D7D),
          selectedFontSize: 16,
          unselectedFontSize: 16,
          items: [
            _buildNavItem('assets/icons/home.svg', '홈'),
            _buildNavItem('assets/icons/quest.svg', '퀘스트'),
            _buildNavItem('assets/icons/profile.svg', '프로필'),
            _buildNavItem('assets/icons/store.svg', '상점'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(assetPath, width: 48, height: 48, colorFilter: const ColorFilter.mode(Color(0xFF7C7D7D), BlendMode.srcIn)),
      activeIcon: SvgPicture.asset(assetPath, width: 48, height: 48, colorFilter: const ColorFilter.mode(Color(0xFF4A90E2), BlendMode.srcIn)),
      label: label,
    );
  }
}