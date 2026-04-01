import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/setting/setting_screen.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;

  // 1. 보호자용 화면 리스트
  final List<Widget> _screens = [
    const Center(child: Text("대시보드 화면")),
    const Center(child: Text("루틴 설정 화면")),
    const Center(child: Text("보상 설정 화면")),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0xFFE3E3E3), width: 1.0),
          ),
        ),
        // 1. Theme 위젯으로 감싸서 스플래시 효과 제거
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF4A90E2),
            unselectedItemColor: const Color(0xFF7C7D7D),

            // 2. 폰트 크기를 동일하게 설정해서 확대 현상 방지
            selectedFontSize: 16,   // 원하는 크기로 설정
            unselectedFontSize: 16, // 선택되지 않았을 때도 동일하게

            items: [
              // 2. 이미지의 아이콘과 이름에 맞게 변경
              _buildNavItem('assets/icons/dashboard.svg', '대시보드'),
              _buildNavItem('assets/icons/routine.svg', '루틴 설정'),
              _buildNavItem('assets/icons/reward.svg', '보상 설정'),
              _buildNavItem('assets/icons/setting.svg', '설정'),
            ],
          ),
        ),
      ),
    );
  }

  // 중복 코드를 줄이기 위한 아이템 생성 함수
  BottomNavigationBarItem _buildNavItem(String assetPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        assetPath,
        width: 48,
        height: 48,
        colorFilter: const ColorFilter.mode(Color(0xFF7C7D7D), BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        assetPath,
        width: 48,
        height: 48,
        colorFilter: const ColorFilter.mode(Color(0xFF4A90E2), BlendMode.srcIn),
      ),
      label: label,
    );
  }
}