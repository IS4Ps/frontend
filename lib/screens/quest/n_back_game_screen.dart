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
  bool isGameFinished = false;
  int currentIndex = 0;
  bool isShowingStimulus = false;

  @override
  void initState() {
    super.initState();
    // 가이드 팝업 없이 바로 API 호출 및 게임 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndStartGame());
  }

  Future<void> _initAndStartGame() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);
    await viewModel.startNBackGame(2); // 2-Back 게임 시작

    if (!mounted) return;

    if (viewModel.nBackData != null) {
      final data = viewModel.nBackData!;
      for (int i = 0; i < data.stimuli.length; i++) {
        if (!mounted) return;
        setState(() {
          currentIndex = i;
          isShowingStimulus = true;
        });
        await Future.delayed(Duration(milliseconds: data.displayTime));
        if (!mounted) return;
        setState(() => isShowingStimulus = false);
        await Future.delayed(Duration(milliseconds: data.intervalTime));
      }
      if (mounted) setState(() => isGameFinished = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.message)));
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
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
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("게임 데이터를 생성하고 있습니다...", style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      )
          : isGameFinished
          ? _buildResultUI()
          : _buildGameUI(nBackData),
    );
  }

  Widget _buildGameUI(dynamic data) {
    if (data == null) return const SizedBox.shrink();
    return Center(
      child: Column(
        children: [
          const Text("도형 순서 기억하기", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: 340, padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                Text("Level - ${data.nLevel - 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("(${data.nLevel}단계 전 기억하기!)", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: Text("진행도 : ${currentIndex + 1} / ${data.totalCount}")),
                const SizedBox(height: 30),
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(15)),
                  child: isShowingStimulus ? Center(child: _getStimulusWidget(data.stimuli[currentIndex].value)) : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: () => print("인덱스 ${data.stimuli[currentIndex].index}에서 일치 클릭"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C92E1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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

  Widget _buildResultUI() {
    return Center(
      child: Container(
        width: 340, padding: const EdgeInsets.all(25),
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
              setState(() { isGameFinished = false; currentIndex = 0; });
              _initAndStartGame();
            }),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("홈으로 돌아가기", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultValue(String title, String value, Color color) {
    return Column(children: [Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)), Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color))]);
  }

  Widget _buildActionBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _getStimulusWidget(String value) {
    switch (value) {
      case 'apple': return const Icon(Icons.favorite, size: 100, color: Color(0xFFE17D7D));
      case 'banana': return const Icon(Icons.circle, size: 100, color: Color(0xFFE17D7D));
      default: return Container(width: 100, height: 100, color: const Color(0xFFE17D7D));
    }
  }
}