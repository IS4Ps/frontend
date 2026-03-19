import 'package:flutter/material.dart';

import 'ox_quiz_screen.dart';

class OxScreen extends StatelessWidget {
  const OxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1586E2),
        elevation: 0,
        leadingWidth: 100,

        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 15, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: const Text(
                '← Back',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
        ),
        title: const Text(
          'OX 퀴즈 이미지 선택',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앨범에서 이미지 선택하기 버튼
            GestureDetector(
              onTap: () {
                // TODO: 앨범 열기
              },
              child: Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1586E2),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '앨범에서 이미지 선택하기',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 선택된 이미지 라벨
            const Text(
              '선택된 이미지',
              style: TextStyle(color: Color(0xFF7C7D7D), fontSize: 15),
            ),

            const SizedBox(height: 12),

            // 이미지 슬롯 4개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildImageSlot()),
            ),

            const Spacer(),

            // 로딩 스피너 + 텍스트
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF1586E2),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI가 이미지를 분석 중이에요!',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 선택 완료 버튼
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OxQuizScreen()),
                  );
                },
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1586E2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      '선택 완료',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 바텀 네비게이션
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 퀘스트 활성
        selectedItemColor: const Color(0xFF1586E2),
        unselectedItemColor: const Color(0xFF7C7D7D),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: '퀘스트'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '상점'),
        ],
      ),
    );
  }

  Widget _buildImageSlot() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
    );
  }
}