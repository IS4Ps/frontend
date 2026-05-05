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

  // 타이머
  Timer? _countdownTimer;
  int _remainingTime = 50; // 초기 시간 50초 설정
  final int _totalStartTime = 50;

  @override
  void initState() {
    super.initState();
    // 화면 렌더링 후 게임 및 타이머 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
      _startSequence();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // 메모리 누수 방지
    super.dispose();
  }

  // 1. 실시간 타이머 시작
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _finishGame(); // 시간 종료 시 게임 종료
      }
    });
  }

  // 2. 게임 시퀀스
  Future<void> _startSequence() async {
    final viewModel = Provider.of<QuestViewModel>(context, listen: false);
    final data = viewModel.nBackData;

    if (data == null) return;

    for (int i = 0; i < data.stimuli.length; i++) {
      if (!mounted || isGameFinished) return;

      setState(() {
        currentIndex = i;
        isShowingStimulus = true;
      });

      // 자극 표시 시간
      await Future.delayed(Duration(milliseconds: data.displayTime));

      if (!mounted || isGameFinished) return;
      setState(() => isShowingStimulus = false);

      // 자극 간 간격 시간
      await Future.delayed(Duration(milliseconds: data.intervalTime));
    }

    _finishGame(); // 모든 자극 소진 시 종료
  }

  // 게임 종료 처리 함수
  void _finishGame() {
    if (_countdownTimer != null) _countdownTimer!.cancel();
    if (mounted) {
      setState(() {
        isGameFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuestViewModel>(context);
    final data = viewModel.nBackData;

    return Scaffold(
      backgroundColor: const Color(0xFFECF2F8), // 부드러운 배경색
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : isGameFinished
            ? _buildResultUI()
            : _buildGameUI(data),
      ),
    );
  }

  Widget _buildGameUI(dynamic data) {
    if (data == null) return const Center(child: Text("데이터 로드 실패"));

    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Go/No-Go',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 타이머 숫자 및 실시간 프로그레스 바
        SizedBox(
          width: 320,
          child: Column(
            children: [
              Text(
                '시간 : $_remainingTime초',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _remainingTime / _totalStartTime, // 시간에 비례해 줄어듦
                  backgroundColor: const Color(0xFFD9D9D9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // 게임 카드
        Center(
          child: Container(
            width: 320,
            height: 480,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('그만하기',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                    Column(
                      children: [
                        Text('Level - ${data.nLevel}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('(초록 원이 나오면 터치!)',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Text('점수 : 100',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),

                // 중앙 자극 표시 영역
                Expanded(
                  child: Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: isShowingStimulus
                            ? const Color(0xFFE57373) // 이미지 속 빨간색 사각형
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // 터치 버튼
                ElevatedButton(
                  onPressed: () {
                    // 터치 로직 추가 위치
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5689D7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 65),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '터치!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 결과 화면
  Widget _buildResultUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 이전 화면으로 돌아가는 상단 백버튼
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
          const Text(
            'Go/No-Go',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('미니게임 성공!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  // 결과 요약 박스
                  _buildGrayBox(
                    child: Column(
                      children: [
                        const Text('게임 결과', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('수고하셨습니다. 총 50문항에 대한 결과입니다.',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 10),
                        _resultRow('맞은 개수', '45개', color: Colors.green),
                        _resultRow('틀린 개수', '5개', color: Colors.red),
                        _resultRow('정확도', '90%'),
                        _resultRow('점수', '1000점'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 지표 박스 (반응속도 & 보상)
                  Row(
                    children: [
                      Expanded(
                        child: _buildGrayBox(
                          child: Column(
                            children: const [
                              Text('평균 반응속도',
                                  style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text('350ms',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGrayBox(
                          child: Column(
                            children: const [
                              Text('획득 보상',
                                  style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text('+n gold',
                                  style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('+n exp',
                                  style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 액션 버튼들
                  _actionButton('난이도 올려서 다시하기', Colors.black, () {}),
                  const SizedBox(height: 10),
                  _actionButton('지금 난이도로 다시하기', const Color(0xFF5689D7), () {
                    // 게임 리셋 로직
                    setState(() {
                      isGameFinished = false;
                      currentIndex = 0;
                      _remainingTime = _totalStartTime;
                    });
                    _startTimer();
                    _startSequence();
                  }),

                  // 이전 화면으로 돌아가는 버튼 (Navigator.pop)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '이전 화면으로 돌아가기',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 컴포넌트 헬퍼 위젯

  Widget _buildGrayBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(15),
      ),
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
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
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
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}