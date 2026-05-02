import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/quest/quest_view_model.dart'; // 프로젝트 경로에 맞게 수정 필요

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
    // 화면 로드 후 가이드 팝업 호출
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuideDialog());
  }

  // 1. 가이드 팝업 (사용자 팁 제공)
  void _showGuideDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("🎮 게임 가이드", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGuideItem("1", "도형이 순서대로 나타납니다."),
            const SizedBox(height: 12),
            _buildGuideItem("2", "지금 도형이 '2단계 전' 것과 같으면\n[일치!] 버튼을 누르세요."),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
              child: const Text("💡 예: □ → ○ → □ (일치 클릭!)", style: TextStyle(fontSize: 12, color: Colors.blue)),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context); // 팝업 닫기
                await _initAndStartGame(); // API 호출 및 게임 시작
              },
              child: const Text("시작하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String label, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 10, backgroundColor: Colors.blue, child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white))),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  // 2. API 데이터 로드 및 게임 루프 실행
  Future<void> _initAndStartGame() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);

    // [API 호출] Level 2 (2-back) 요청
    await viewModel.startNBackGame(2);

    if (!mounted) return;

    // 데이터 로드 성공 시 게임 애니메이션 시작
    if (viewModel.nBackData != null) {
      final data = viewModel.nBackData!;

      for (int i = 0; i < data.stimuli.length; i++) {
        if (!mounted) return;

        setState(() {
          currentIndex = i;
          isShowingStimulus = true;
        });

        // 서버에서 준 표시 시간(ms)만큼 대기
        await Future.delayed(Duration(milliseconds: data.displayTime));

        if (!mounted) return;
        setState(() => isShowingStimulus = false);

        // 서버에서 준 자극 간격 시간(ms)만큼 대기
        await Future.delayed(Duration(milliseconds: data.intervalTime));
      }

      if (mounted) setState(() => isGameFinished = true);
    } else {
      // 실패 시 ViewModel에 저장된 에러 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);
    final nBackData = viewModel.nBackData;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator()) // 데이터를 가져오는 중일 때 로딩 표시
          : isGameFinished
          ? _buildResultUI()
          : _buildGameUI(nBackData),
    );
  }

  // 3. 메인 게임 UI (서버 데이터 바인딩)
  Widget _buildGameUI(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return Center(
      child: Column(
        children: [
          const Text("도형 순서 기억하기", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: 340,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                Text("Level - ${data.nLevel - 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("(${data.nLevel}단계 전 기억하기!)", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text("진행도 : ${currentIndex + 1} / ${data.totalCount}")
                ),
                const SizedBox(height: 30),

                // 자극 표시 박스 (서버에서 온 value 값에 따라 렌더링)
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(15)),
                  child: isShowingStimulus
                      ? Center(child: _getStimulusWidget(data.stimuli[currentIndex].value))
                      : null,
                ),

                const SizedBox(height: 40),

                // 일치 버튼
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // 정답 기록용 로그 (추후 정답 제출 API 연동 시 사용)
                      print("인덱스 ${data.stimuli[currentIndex].index}에서 일치 클릭");
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

  // 4. 결과 UI
  Widget _buildResultUI() {
    return Center(
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("미니게임 성공!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF1F3F7), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text("게임 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("수고하셨습니다. 총 20문항에 대한 결과입니다.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 25),
                  _buildResultValue("정답", "15개", const Color(0xFF8CD85A)),
                  const SizedBox(height: 15),
                  _buildResultValue("오답", "5개", Colors.redAccent),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildActionBtn("난이도 올려서 다시하기", Colors.black, () {}),
            const SizedBox(height: 12),
            _buildActionBtn("지금 난이도로 다시하기", const Color(0xFF5C92E1), () {
              setState(() {
                isGameFinished = false;
                currentIndex = 0;
              });
              _initAndStartGame();
            }),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("홈으로 돌아가기", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultValue(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 5. 서버 가상 데이터 값에 따른 실제 위젯 생성
  Widget _getStimulusWidget(String value) {
    switch (value) {
      case 'apple':
        return const Icon(Icons.favorite, size: 100, color: Color(0xFFE17D7D));
      case 'banana':
        return const Icon(Icons.circle, size: 100, color: Color(0xFFE17D7D));
      default:
        return Container(width: 100, height: 100, color: const Color(0xFFE17D7D));
    }
  }
}