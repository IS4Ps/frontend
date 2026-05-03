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
                  const Text('보상 기간', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPeriodTab('주간', Icons.calendar_today_rounded, viewModel.isWeekly, () {
                        viewModel.togglePeriod(true);
                        viewModel.fetchOfflineRewards();
                      }),
                      const SizedBox(width: 12),
                      _buildPeriodTab('월간', Icons.calendar_month_rounded, !viewModel.isWeekly, () {
                        viewModel.togglePeriod(false);
                        viewModel.fetchOfflineRewards();
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '선택한 동안의 루틴 달성률에 따라 보상이 주어집니다',
                    style: TextStyle(color: Color(0XFF7C7D7D), fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('달성률별 보상 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      GestureDetector(
                        onTap: () => viewModel.addRewardStep(),
                        child: const Text(
                          '+ 단계추가',
                          style: TextStyle(color: Color(0xFFDD00FF), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...viewModel.editingRewards.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var reward = entry.value;
                      return _buildRewardCard(idx, reward.targetPercent.toString(), reward.rewardPromiseText, viewModel);
                    }).toList(),
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
      child: const Text('보상 설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
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
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black87 : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(int index, String percent, String rewardContent, RewardViewModel viewModel) {
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
              // 달성률 TextField
              Container(
                width: 54, height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  onChanged: (val) => viewModel.updateRewardEntry(index, percent: int.tryParse(val)),
                  controller: TextEditingController.fromValue(TextEditingValue(
                    text: percent == "0" ? "" : percent,
                    selection: TextSelection.collapsed(offset: percent == "0" ? 0 : percent.length),
                  )),
                ),
              ),
              const SizedBox(width: 8),
              const Text('% 달성 시', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              // 삭제 버튼 (X)
              GestureDetector(
                onTap: () => viewModel.removeRewardStep(index),
                child: const Icon(Icons.close, color: Color(0xFFFF0000), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 보상 종류 TextField
              Expanded(
                flex: 3,
                child: _buildEditableInputBox(
                    rewardContent,
                    '보상 종류(예: 게임 시간, 용돈)',
                        (val) => viewModel.updateRewardEntry(index, text: val)
                ),
              ),
              const SizedBox(width: 12),
              // 수량/금액 TextField
              Expanded(
                flex: 1,
                child: _buildEditableInputBox('', '수량/금액', (val) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInputBox(String value, String hint, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF7C7D7D), width: 0.55),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7C7D7D), fontSize: 12),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        controller: TextEditingController.fromValue(TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        )),
      ),
    );
  }
}