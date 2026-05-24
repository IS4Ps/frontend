import 'package:flutter/material.dart';
import 'dart:async';

class RoutineDetailScreen extends StatefulWidget {
  final String taskTitle;
  final String mainQuestTitle;
  final String startTime;
  final String endTime;
  final int remainingSeconds;
  final int totalSeconds;
  final Function(int)? onTimerUpdate;

  const RoutineDetailScreen({
    super.key,
    required this.taskTitle,
    required this.mainQuestTitle,
    required this.startTime,
    required this.endTime,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.onTimerUpdate,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  double _progress = 1.0;
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.remainingSeconds;
    _totalSeconds = widget.totalSeconds;
    _progress = _remainingSeconds / _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        setState(() {
          timer.cancel();
          _remainingSeconds = 0;
          _progress = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
          _progress = _remainingSeconds / _totalSeconds;
        });
        widget.onTimerUpdate?.call(_remainingSeconds);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTimeOver = _remainingSeconds <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Text(
              widget.mainQuestTitle,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),

            Column(
              children: [
                Text(
                  widget.taskTitle,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "얼른 진행하세요!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 15,
                    backgroundColor: const Color(0xFFE3E3E3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTimeOver ? Colors.red : const Color(0xFF6389E9),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 45,
                      color: isTimeOver ? Colors.red : const Color(0xFF6389E9),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: isTimeOver ? Colors.red : Colors.black,
                      ),
                    ),
                    if (isTimeOver)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "시간 초과!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6389E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF6389E9).withOpacity(0.4),
                  ),
                  child: const Text(
                    "다음 퀘스트로!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}