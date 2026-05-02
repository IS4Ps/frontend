import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/reward/reward_view_model.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 오프라인 보상 목록 로드
    Future.microtask(() => context.read<RewardViewModel>().fetchOfflineRewards());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RewardViewModel>();

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
                      _buildPeriodTab('주간', Icons.calendar_today_rounded, viewModel.isWeekly, () {
                        viewModel.togglePeriod(true);
                      }),
                      const SizedBox(width: 12),
                      _buildPeriodTab('월간', Icons.calendar_month_rounded, !viewModel.isWeekly, () {
                        viewModel.togglePeriod(false);
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
                        onTap: () {
                          // TODO: 등록 API(POST) 연동 시 활용
                        },
                        child: const Text(
                          '+ 단계추가',
                          style: TextStyle(color: Color(0xFFDD00FF), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. 보상 카드 리스트 (API 연동 및 기존 UI 유지)
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.filteredRewards.isEmpty)
                  // 데이터가 0개일 때 기존 UI 형태 유지를 위해 빈 카드 노출
                    Column(
                      children: [
                        _buildRewardCard('50', '보상 종류(예: 게임 시간, 용돈, 놀이공원)'),
                        _buildRewardCard('70', '보상 종류(예: 게임 시간, 용돈, 놀이공원)'),
                        _buildRewardCard('100', '보상 종류(예: 게임 시간, 용돈, 놀이공원)'),
                      ],
                    )
                  else
                  // 데이터가 있을 때 서버 데이터로 카드 생성
                    Column(
                      children: viewModel.filteredRewards.map((reward) =>
                          _buildRewardCard(
                              reward.targetPercent.toString(),
                              reward.rewardPromiseText
                          )
                      ).toList(),
                    ),
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

  Widget _buildRewardCard(String percent, String rewardHint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
                  borderRadius: BorderRadius.circular(6),
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
              const Icon(Icons.close, color: Color(0xFFFF0000), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildInputBox(rewardHint),
              ),
              const SizedBox(width: 12),
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

  Widget _buildInputBox(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
      ),
      child: Text(
        hint,
        style: const TextStyle(color: Color(0xFF7C7D7D), fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}