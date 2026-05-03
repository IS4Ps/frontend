import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/quest/quest_view_model.dart';

class NBackGameScreen extends StatefulWidget {
  const NBackGameScreen({super.key});

  @override
  State<NBackGameScreen> createState() => _NBackGameScreenState();
}

class _NBackGameScreenState extends State<NBackGameScreen> {
  // 상태 제어 변수
  bool isGameFinished = false;
  int currentIndex = 0;
  bool isShowingStimulus = false;

  @override
  void initState() {
    super.initState();
    // 화면 로드 직후 API 데이터 확인 및 게임 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
  }

  // 1. 게임 시퀀스 실행 (서버 데이터 기반 자동 루프)
  Future<void> _startSequence() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);
    final data = viewModel.nBackData;

    // 데이터가 없으면 시작하지 않음 (이전 화면에서 이미 호출되었다고 가정)
    if (data == null) return;

    for (int i = 0; i < data.stimuli.length; i++) {
      if (!mounted) return;

      setState(() {
        currentIndex = i;
        isShowingStimulus = true;
      });

      // 서버가 정해준 표시 시간(displayTime)만큼 대기
      await Future.delayed(Duration(milliseconds: data.displayTime));

      if (!mounted) return;
      setState(() => isShowingStimulus = false);

      // 서버가 정해준 자극 간격(intervalTime)만큼 대기
      await Future.delayed(Duration(milliseconds: data.intervalTime));
    }

    if (mounted) setState(() => isGameFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);
    final data = viewModel.nBackData;

    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isGameFinished
          ? _buildResultUI()
          : _buildGameUI(data),
    );
  }

  // 2. 메인 게임 UI (서버 데이터 바인딩)
  Widget _buildGameUI(dynamic data) {
    if (data == null) return const Center(child: Text("데이터를 불러오지 못했습니다."));

    return Center(
      child: Column(
        children: [
          const Text("도형 순서 기억하기", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: 340,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: [
                Text("Level - ${data.nLevel - 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("(${data.nLevel}단계 전 기억하기!)", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("그만하기", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                    ),
                    Text("진행도 : ${currentIndex + 1} / ${data.totalCount}", style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(15)),
                  child: isShowingStimulus
                      ? Center(child: _getStimulusWidget(data.stimuli[currentIndex].value))
                      : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // 일치 버튼 클릭 시 로그 기록 (추후 정답 제출 API 연동용)
                      print("사용자가 ${data.stimuli[currentIndex].index}번 자극에서 일치 클릭");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C92E1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("일치!", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(width: 340, height: 150, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(20))),
        ],
      ),
    );
  }

  // 3. 결과 UI
  Widget _buildResultUI() {
    return Center(
      child: Column(
        children: [
          const Text("도형 순서 기억하기", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: 340,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("미니게임 성공!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                      color: const Color(0xFFECF2F8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.05))
                  ),
                  child: Column(
                    children: [
                      const Text("게임 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("수고하셨습니다. 총 20문항에 대한 결과입니다.", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 25),
                      _buildDetailResult("정답", "15개", const Color(0xFF8CD85A), "일치할 때 누름 + 불일치일 때 안 누름"),
                      const SizedBox(height: 20),
                      _buildDetailResult("오답", "5개", Colors.redAccent, "불일치인데 누름 + 일치인데 안 누름"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFF1F3F7), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      const Text("획득 보상", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text("+n gold", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("+n exp", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildActionBtn("난이도 올려서 다시하기", Colors.black, () {}),
                const SizedBox(height: 12),
                _buildActionBtn("지금 난이도로 다시하기", const Color(0xFF5C92E1), () {
                  setState(() {
                    isGameFinished = false;
                    currentIndex = 0;
                  });
                  _startSequence(); // 게임 재시작
                }),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("홈으로 돌아가기", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailResult(String title, String value, Color color, String description) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
        Text(description, style: const TextStyle(fontSize: 10, color: Colors.black38)),
      ],
    );
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  // 서버의 String 값(apple, banana 등)에 따라 위젯 매핑
  Widget _getStimulusWidget(String value) {
    switch (value) {
      case 'apple': return const Icon(Icons.favorite, size: 100, color: Color(0xFFE17D7D));
      case 'banana': return const Icon(Icons.circle, size: 100, color: Color(0xFFE17D7D));
      case 'clover': return const Icon(Icons.eco, size: 100, color: Color(0xFFE17D7D));
      default: return Container(width: 100, height: 100, color: const Color(0xFFE17D7D));
    }
  }
}