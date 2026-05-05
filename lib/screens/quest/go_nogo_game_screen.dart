import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/quest/quest_view_model.dart';

class GoNogoGameScreen extends StatefulWidget {
  const GoNogoGameScreen({super.key});

  @override
  State<GoNogoGameScreen> createState() => _GoNogoGameScreenState();
}

class _GoNogoGameScreenState extends State<GoNogoGameScreen> {
  // 상태 제어 변수
  bool isGameFinished = false;
  int currentIndex = 0;
  bool isShowingStimulus = false;

  // --- 타이머 변수 ---
  Timer? _countdownTimer;
  int _remainingTime = 50;
  final int _totalStartTime = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimer();
        _startSequence();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // 실시간 타이머
  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _finishGame();
      }
    });
  }

  // 게임 시퀀스 로직 (Go/No-Go 전용 데이터 사용)
  Future<void> _startSequence() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);
    // ◀ nBackData 대신 goNoGoData 사용
    final data = viewModel.goNoGoData;

    if (data == null) return;

    for (int i = 0; i < data.stimuli.length; i++) {
      if (!mounted || isGameFinished) break;

      setState(() {
        currentIndex = i;
        isShowingStimulus = true;
      });

      // 명세서의 timeLimit(ms) 동안 자극 노출
      await Future.delayed(Duration(milliseconds: data.timeLimit));

      if (!mounted || isGameFinished) break;
      setState(() => isShowingStimulus = false);

      // 자극 사이의 대기 시간 (예: 500ms)
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted && !isGameFinished) _finishGame();
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    if (mounted) setState(() => isGameFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);
    // ◀ goNoGoData 참조
    final data = viewModel.goNoGoData;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: data == null
            ? const Center(child: CircularProgressIndicator())
            : isGameFinished
            ? _buildResultUI()
            : _buildGameUI(data),
      ),
    );
  }

  // 메인 게임 UI
  Widget _buildGameUI(dynamic data) {
    // 현재 표시해야 할 자극 데이터 (type, image 포함)
    final currentStimulus = data.stimuli[currentIndex];

    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('Go/No-Go', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // 시간 표시 및 프로그레스 바
        SizedBox(
          width: 320,
          child: Column(
            children: [
              Text('시간 : $_remainingTime초', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

        // 메인 카드
        Center(
          child: Container(
            width: 320,
            height: 480,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('그만하기', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                    Column(
                      children: const [
                        Text('Level - 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('(초록 원이 나오면 터치!)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Text('점수 : 100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),

                // 중앙 자극 영역
                Expanded(
                  child: Center(
                    child: isShowingStimulus
                        ? _getStimulusWidget(currentStimulus.image)
                        : const SizedBox.shrink(),
                  ),
                ),

                // 터치 버튼 (GO 타입일 때만 정답 처리)
                ElevatedButton(
                  onPressed: () {
                    if (isShowingStimulus) {
                      bool isCorrect = currentStimulus.type == "GO";
                      print(isCorrect ? "정답! (GO 클릭)" : "오답! (NOGO 클릭)");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5689D7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 65),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('터치!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 서버의 image 문자열 값에 따라 위젯 매핑
  Widget _getStimulusWidget(String imageName) {
    switch (imageName) {
      case 'monster_green': // GO 자극 예시
        return const Icon(Icons.sentiment_very_satisfied, size: 120, color: Colors.green);
      case 'bomb_red': // NOGO 자극 예시
        return const Icon(Icons.dangerous, size: 120, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, size: 120, color: Colors.grey);
    }
  }

  // 결과 UI
  Widget _buildResultUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const Text('Go/No-Go', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text('미니게임 성공!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildGrayBox(
                    child: Column(
                      children: [
                        const Text('게임 결과', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('수고하셨습니다. 총 20문항에 대한 결과입니다.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 10),
                        _resultRow('맞은 개수', '18개', color: Colors.green),
                        _resultRow('틀린 개수', '2개', color: Colors.red),
                        _resultRow('정확도', '90%'),
                        _resultRow('점수', '900점'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildGrayBox(child: Column(children: const [Text('평균 반응속도', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), SizedBox(height: 10), Text('350ms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildGrayBox(child: Column(children: const [Text('획득 보상', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), SizedBox(height: 10), Text('+n gold', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('+n exp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _actionButton('난이도 올려서 다시하기', Colors.black, () {}),
                  const SizedBox(height: 10),
                  _actionButton('지금 난이도로 다시하기', const Color(0xFF5689D7), () {
                    if (mounted) {
                      setState(() {
                        isGameFinished = false;
                        currentIndex = 0;
                        _remainingTime = _totalStartTime;
                      });
                      _startTimer();
                      _startSequence();
                    }
                  }),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('이전 화면으로 돌아가기', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 헬퍼 위젯 ---
  Widget _buildGrayBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }

  Widget _resultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color bgColor, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}