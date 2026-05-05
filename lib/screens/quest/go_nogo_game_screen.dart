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
  bool isGameFinished = false;
  int currentIndex = 0;
  bool isShowingStimulus = false;

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

  // 게임 시퀀스 로직
  Future<void> _startSequence() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);

    // 데이터를 가져오되, Map 형태로 캐스팅하여 에러 방지
    final rawData = viewModel.nBackData ?? _getDummyData();
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);

    final List stimuliList = data['stimuli'] as List;

    for (int i = 0; i < stimuliList.length; i++) {
      if (!mounted || isGameFinished) break;

      setState(() {
        currentIndex = i;
        isShowingStimulus = true;
      });

      await Future.delayed(Duration(milliseconds: data['displayTime'] ?? 1000));

      if (!mounted || isGameFinished) break;
      setState(() => isShowingStimulus = false);

      await Future.delayed(Duration(milliseconds: data['intervalTime'] ?? 500));
    }

    if (mounted && !isGameFinished) _finishGame();
  }

  // UI 확인용 더미 데이터
  Map<String, dynamic> _getDummyData() {
    return {
      'nLevel': 1,
      'totalCount': 20,
      'displayTime': 1000,
      'intervalTime': 500,
      'stimuli': List.generate(20, (index) => {'index': index, 'value': 'circle'}),
    };
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    if (mounted) setState(() => isGameFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);

    // 데이터 타입을 명시적으로 지정
    final rawData = viewModel.nBackData ?? _getDummyData();
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: isGameFinished
            ? _buildResultUI()
            : _buildGameUI(data),
      ),
    );
  }

  // 메인 게임 UI (data['키값']
  Widget _buildGameUI(Map<String, dynamic> data) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('Go/No-Go', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
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
                      children: [
                        Text('Level - ${data['nLevel'] ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('(초록 원이 나오면 터치!)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Text('점수 : 100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        color: isShowingStimulus ? const Color(0xFFE57373) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
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
                        const Text('수고하셨습니다. 총 50문항에 대한 결과입니다.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 10),
                        _resultRow('맞은 개수', '45개', color: Colors.green),
                        _resultRow('틀린 개수', '5개', color: Colors.red),
                        _resultRow('정확도', '90%'),
                        _resultRow('점수', '1000점'),
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
                    child: const Text('홈 화면으로 돌아가기', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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