import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/quest/quest_view_model.dart';

class StroopGameScreen extends StatefulWidget {
  const StroopGameScreen({super.key});

  @override
  State<StroopGameScreen> createState() => _StroopGameScreenState();
}

class _StroopGameScreenState extends State<StroopGameScreen> {
  // 게임 상태 관리
  bool isGameFinished = false;
  int _remainingTime = 50;
  final int _totalStartTime = 50;
  Timer? _countdownTimer;

  // 문제 관련 데이터 (Stroop 효과용)
  final Map<String, Color> gameColors = {
    '빨강': const Color(0xFFEF5350),
    '파랑': const Color(0xFF42A5F5),
    '초록': const Color(0xFF8BC34A),
    '노랑': const Color(0xFFFFEB3B),
  };

  late String currentText;
  late Color currentTextColor;
  int score = 100;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _finishGame();
      }
    });
  }

  void _generateNewQuestion() {
    final names = gameColors.keys.toList();
    final random = Random();
    setState(() {
      currentText = names[random.nextInt(names.length)];
      String colorName;
      do {
        colorName = names[random.nextInt(names.length)];
      } while (colorName == currentText);
      currentTextColor = gameColors[colorName]!;
    });
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    if (mounted) setState(() => isGameFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);

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
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isGameFinished
              ? _buildResultUI(viewModel)
              : _buildGameUI(),
        ),
      ),
    );
  }

  // 메인 게임
  Widget _buildGameUI() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text('단어 색깔 구별하기', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        SizedBox(
          width: 320,
          child: Column(
            children: [
              Text('시간 : $_remainingTime초', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _remainingTime / _totalStartTime,
                  backgroundColor: const Color(0xFFD9D9D9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('그만하기', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                    const Text('Level - 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('점수 : $score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFDEE2E6)),
                  ),
                  child: Center(
                    child: Text(
                      currentText,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: currentTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text('아래에서 글자 색에 해당하는 칸을 누르세요', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: gameColors.entries.map((e) => _buildColorSelectionBtn(e.key, e.value)).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 결과 화면
  Widget _buildResultUI(QuestViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('단어 색깔 구별하기', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text('미니게임 성공!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  _buildGrayBox(
                    child: Column(
                      children: [
                        const Text('게임 결과', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text('수고하셨습니다. 총 n문항에 대한 결과입니다.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 15),
                        _resultRow('맞은 개수', 'n개', color: Colors.green),
                        _resultRow('틀린 개수', 'n개', color: Colors.red),
                        _resultRow('정확도', 'n%'),
                        _resultRow('점수', 'n점'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildGrayBox(child: _buildInfoItem('평균 반응속도', '350ms'))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildGrayBox(child: _buildInfoItem('획득 보상', '+n gold\n+n exp'))),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 1. 난이도 올려서 다시하기 (검정 버튼)
                  _actionButton('난이도 올려서 다시하기', Colors.black, () {
                    // 여기에 난이도 변경 로직 추가 가능
                  }),
                  const SizedBox(height: 12),

                  // 2. 지금 난이도로 다시하기 (파란 버튼)
                  _actionButton('지금 난이도로 다시하기', const Color(0xFF5C92E1), () {
                    setState(() {
                      isGameFinished = false;
                      _remainingTime = _totalStartTime;
                      score = 100;
                    });
                    _startTimer();
                    _generateNewQuestion();
                  }),
                  const SizedBox(height: 8),

                  // 3. 홈으로 돌아가기 (텍스트 버튼)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        '홈 화면으로 돌아가기',
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelectionBtn(String label, Color color) {
    return ElevatedButton(
      onPressed: _generateNewQuestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: const BorderSide(color: Color(0xFFDEE2E6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Row(
        children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGrayBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFECF2F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _resultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label : ', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color bgColor, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}