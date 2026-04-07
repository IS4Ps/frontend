import 'package:flutter/material.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool isWeekly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 보상 기간 섹션
                  const Text('보상 기간', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPeriodTab('주간', Icons.calendar_today_rounded, isWeekly, () {
                        setState(() => isWeekly = true);
                      }),
                      const SizedBox(width: 12),
                      _buildPeriodTab('월간', Icons.calendar_month_rounded, !isWeekly, () {
                        setState(() => isWeekly = false);
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '선택한 동안의 루틴 달성률에 따라 보상이 주어집니다',
                    style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 16),
                  ),

                  const SizedBox(height: 32),

                  // 2. 달성률별 보상 설정 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('달성률별 보상 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          '+ 단계추가',
                          style: TextStyle(color: Color(0xFFDD00FF), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. 보상 카드 리스트 (개별 카드 스타일)
                  _buildRewardCard('50'),
                  _buildRewardCard('70'),
                  _buildRewardCard('100'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
              '보상 설정',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
          ),
          SizedBox(height: 2),
          Text(
              '',
              style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 12)
          ),
        ],
      ),
    );
  }

  // 주간/월간 탭 (이미지 스타일 반영)
  Widget _buildPeriodTab(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA6C8FF) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black87 : Colors.grey, size: 28),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 보상 단계 카드
  Widget _buildRewardCard(String percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        // 1. 전체 카드의 모서리를 이미지처럼 크게 둥글게 처리
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 2. 숫자 입력 박스 (알약 모양 테두리)
              Container(
                width: 54,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
                  borderRadius: BorderRadius.circular(6), // 살짝 둥근 사각형
                ),
                alignment: Alignment.center,
                child: Text(
                    percent,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              const SizedBox(width: 8),
              const Text('% 달성 시', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              // 3. X 아이콘 (빨간색)
              const Icon(Icons.close, color: Color(0xFFFF0000), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 4. 보상 종류 입력창
              Expanded(
                flex: 3,
                child: _buildInputBox('보상 종류(예: 게임 시간, 용돈, 놀이공원)'),
              ),
              const SizedBox(width: 12),
              // 5. 수량/금액 입력창
              Expanded(
                flex: 1,
                child: _buildInputBox('수량/금액'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 내부 입력 박스 스타일
  Widget _buildInputBox(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        // 6. 이미지처럼 입력칸 테두리를 아주 둥글게 처리
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
      ),
      child: Text(
        hint,
        style: const TextStyle(color: Color(0xFF7C7D7D), fontSize: 12),
        overflow: TextOverflow.ellipsis, // 글자가 길면 생략
      ),
    );
  }
}